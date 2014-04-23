From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: basic question about LRO implementation
Date: Wed, 23 Apr 2014 09:15:57 +0530
Message-ID: <CAJ3bTp4v9e4rXDh1-MzM13jsj6j56WJQa76GWwhXeOAx-fpg8A@mail.gmail.com>
References: <CAJ3bTp5v5jbpfnc78YXXEbYxOYpWnkz7UioznwszrvqcuHjD=Q@mail.gmail.com>
	<1398174850.29946.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:49522 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbaDWDp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 23:45:58 -0400
Received: by mail-qa0-f50.google.com with SMTP id ih12so370989qab.9
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 20:45:57 -0700 (PDT)
In-Reply-To: <1398174850.29946.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you.

On Tue, Apr 22, 2014 at 7:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-04-22 at 13:28 +0530, Rayagond Kokatanur wrote:
>> Hi All,
>>
>> As part of LRO support, every Ethernet driver has to implement a call
>> back function ".get_skb_header" which does following,
>>
>> 1. Checks for TCP packet and return 0 for TCP packet and -1 for non-tcp packets
>> 2. Get tcp and ip header from given skb
>> 3. Initialize the flag to indicate IPv4 and  TCP packet.
>>
>> All these can be done by using skb - which is passed as input argument
>> to get_skb_header, there is nothing device specific we do in this api,
>> hence why can't this be implemented as generic api. By this way we can
>> avoid every driver implementing same api and hence duplicating the
>> same code.
>>
>> Please let me know if my understanding may be wrong.
>
> LRO is deprecated.
>
> Use GRO, even if hardware assisted like bnx2x driver ?
>
>
>
