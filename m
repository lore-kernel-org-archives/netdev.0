From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: WARNING, net/core/dev.c, =?UTF-8?Q?skb=5Fgso=5Fsegment=2C=20?=  =?UTF-8?Q?=32=2E=36=2E=33=39-rc=37-git=31=31=20inclusive?=
Date: Tue, 17 May 2011 16:25:17 +0300
Message-ID: <8dc4f8b5ba4b1a349b4379394c0979d9@visp.net.lb>
References: <75df1ebd245faa29f6d9c067bad94e8e@visp.net.lb>
 <1305638195.2850.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:33350 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754662Ab1EQNZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 09:25:20 -0400
In-Reply-To: <1305638195.2850.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> --
>
> Hi Denys
>
> net/sched/act_csum.c sets skb->ip_summed = CHECKSUM_NONE;  after csum
> changes.
>
> and skb_gso_segment() barfs if skb->ip_summed != CHECKSUM_PARTIAL
>
> You could disable GRO for the time being.
 Thanks a lot, i will, it is just test.
 By the way, is it a bug and it will be fixed, or pedit is not intended 
 to be (ab)used like that?

