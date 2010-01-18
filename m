From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 20:36:45 +0100
Message-ID: <20100118193645.GH16482@nuttenaction>
References: <4B548DAE.3000205@trash.net>
 <1263833050-11635-1-git-send-email-hagen@jauu.net>
 <4B54B59D.5010108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:41689 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751638Ab0ARTgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:36:47 -0500
Content-Disposition: inline
In-Reply-To: <4B54B59D.5010108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jarek Poplawski | 2010-01-18 20:25:17 [+0100]:

>I don't think this is needed; qdisc_dequeue_head() updated it already.

No, the bookkeeping stuff is done in the previous call layer. It is not really
nice solved but to generalize this stuff adds unnecessary overhead.

>> +	.drop		=	qdisc_queue_drop,
>
>Probably it isn't used much, but it seems for consistency this drop
>should be implemented as a head drop.

Sounds coherent, Patrick should I brew a new patch?

HGN

PS: Jarek thank you for your notes, I will incorporate these!
