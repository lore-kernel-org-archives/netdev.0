From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: WARNING, net/core/dev.c, =?UTF-8?Q?skb=5Fgso=5Fsegment=2C=20?=  =?UTF-8?Q?=32=2E=36=2E=33=39-rc=37-git=31=31=20inclusive?=
Date: Tue, 17 May 2011 16:31:59 +0300
Message-ID: <4cafcd5ed8ecce483cbdcbb3c223ccf5@visp.net.lb>
References: <75df1ebd245faa29f6d9c067bad94e8e@visp.net.lb>
 <1305638195.2850.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:40236 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754446Ab1EQNcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 09:32:01 -0400
In-Reply-To: <1305638195.2850.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Tue, 17 May 2011 15:16:35 +0200, Eric Dumazet wrote:
>
> Hi Denys
>
> net/sched/act_csum.c sets skb->ip_summed = CHECKSUM_NONE;  after csum
> changes.
>
> and skb_gso_segment() barfs if skb->ip_summed != CHECKSUM_PARTIAL
>
> You could disable GRO for the time being.
 It seems mistake from my side, seems, csum was not being called, i 
 forgot to add pipe before csum.

