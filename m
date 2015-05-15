From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2] rocker: fix a neigh entry leak issue
Date: Fri, 15 May 2015 10:30:18 +0800
Message-ID: <55555A3A.6030201@windriver.com>
References: <1431653605-11922-1-git-send-email-ying.xue@windriver.com> <20150514.222624.838893967441144984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<jiri@resnulli.us>, <sfeldma@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45360 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423492AbbEOCa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:30:27 -0400
In-Reply-To: <20150514.222624.838893967441144984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 10:26 AM, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Fri, 15 May 2015 09:33:25 +0800
> 
>> Once we get a neighbour through looking up arp cache or creating a
>> new one in rocker_port_ipv4_resolve(), the neighbour's refcount is
>> already taken. But as we don't put the refcount again after it's
>> used, this makes the neighbour entry leaked.
>>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
>> Acked-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> ---
>> v2:
>>   Add the checking of return value of neigh_create() with IS_ERR()
>>   to avoid another crash, which is suggested by Eric Dumazet.
> 
> Doesn't this leak exist in the 'net' tree?
> 
> If so, why are you targetting such a bug fix for 'net-next'?
> 
> 

Sorry, I am used to develop in net-next tree. Please wait a moment, I will check
whether the issue also exists in net tree.

Regards,
Ying
