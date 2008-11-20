From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched: add DRR scheduler
Date: Thu, 20 Nov 2008 04:10:11 -0800 (PST)
Message-ID: <20081120.041011.204454995.davem@davemloft.net>
References: <20081120113557.GA5275@ff.dom.local>
	<49254D42.10506@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbYKTMKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:10:11 -0500
In-Reply-To: <49254D42.10506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 20 Nov 2008 12:42:58 +0100

> commit c6e712b1cf9446096159414cb9d7f8c58effe92f
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Nov 20 12:39:18 2008 +0100
> 
>     pkt_sched: add DRR scheduler
>     
>     Add classful DRR scheduler as a more flexible replacement for SFQ.
>     
>     The main difference to the algorithm described in "Efficient Fair Queueing
>     using Deficit Round Robin" is that this implementation doesn't drop packets
>     from the longest queue on overrun because its classful and limits are
>     handled by each individual child qdisc.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

