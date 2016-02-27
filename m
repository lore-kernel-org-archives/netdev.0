From: Stafford Horne <shorne@gmail.com>
Subject: Re: [PATCH 3/3] 3c59x: Use setup_timer()
Date: Sun, 28 Feb 2016 03:48:11 +0900 (JST)
Message-ID: <alpine.LFD.2.20.1602280338040.17144@lianli.shorne-pla.net>
References: <20160224135819.GA14426@amitoj-Inspiron-3542> <20160225.165218.2138194136809439003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: amitoj1606@gmail.com, klassert@mathematik.tu-chemnitz.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34104 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756657AbcB0SsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 13:48:25 -0500
In-Reply-To: <20160225.165218.2138194136809439003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 25 Feb 2016, David Miller wrote:

> From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Date: Wed, 24 Feb 2016 19:28:19 +0530
>
>> Convert a call to init_timer and accompanying intializations of
>> the timer's data and function fields to a call to setup_timer.
>>
>> The Coccinelle semantic patch that fixes this problem is
>> as follows:
>>
>> // <smpl>
>> @@
>> expression t,f,d;
>> @@
>>
>> -init_timer(&t);
>> +setup_timer(&t,f,d);
>>  ...
>> -t.data = d;
>> -t.function = f;
>> // </smpl>
>>
>> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
>
> Applied.

Hi David, Amitoj,

The patch here seemed to remove the call to add_timer(&vp->timer) which
applies the expires time. Would that be an issue?

-Stafford
