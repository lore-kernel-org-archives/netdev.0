From: Patrick McHardy <kaber@trash.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 17:27:29 +0200
Message-ID: <487B7061.5040306@trash.net>
References: <20080710223141.GA2519@orion.carnet.hr>	<20080710.162007.04790623.davem@davemloft.net>	<20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, joy@entuzijast.net,
	mchan@broadcom.com, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49481 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbYGNP3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 11:29:03 -0400
In-Reply-To: <4878AFD8.1000307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 07/12/2008 11:49 AM:
> 
>> This isn't correct: htb_activate() needs cl->un.leaf.q->q.qlen > 0, and
>> only NET_XMIT_SUCCESS can guarantee this.
> 
> 
> ...Actually, it looks like even NET_XMIT_SUCCESS can't guarantee this
> (when returned after TC_ACT_QUEUED or TC_ACT_STOLEN), so additional qlen
> test is needed here.

The TC action code translation needs to be fixed instead.

I didn't manage to work on this this weekend as I intended, but
I'll take care of it soon unless someone beats me to it.
