From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Mon, 6 Jul 2009 20:02:14 +0930
Message-ID: <20090706200214.7767fd6a.lk-netdev@lk-netdev.nosense.org>
References: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
	<20090620105325.GC31266@Chamillionaire.breakpoint.cc>
	<20090705.194705.179239113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, lk-netdev@lk-netdev.nosense.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:46188 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbZGFKcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 06:32:24 -0400
In-Reply-To: <20090705.194705.179239113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Sun, 05 Jul 2009 19:47:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 20 Jun 2009 12:53:25 +0200
> 
> > Subject: [PATCH] net: remove NET_RX_BAD and NET_RX_CN* defines
> > 
> > almost no users in the tree; and the few that use them treat them
> > like NET_RX_DROP.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Applied to net-next-2.6

Will my first econet patch go in? It was just a "no magic numbers"
patch, unrelated to the NET_RX_DROP vs NET_RX_BAD issue.

Regards,
Mark.
