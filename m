From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 2/2] l2tp: fix userspace reception on plain L2TP
 sockets
Date: Thu, 06 Mar 2014 14:26:09 -0500 (EST)
Message-ID: <20140306.142609.347473249771565688.davem@davemloft.net>
References: <cover.1393966618.git.g.nault@alphalink.fr>
	<bf7ad9b2fdf97c35d2c07488eea09e5280627b74.1394100210.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbaCFT0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:26:12 -0500
In-Reply-To: <bf7ad9b2fdf97c35d2c07488eea09e5280627b74.1394100210.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 6 Mar 2014 11:15:10 +0100

> As pppol2tp_recv() never queues up packets to plain L2TP sockets,
> pppol2tp_recvmsg() never returns data to userspace, thus making
> the recv*() system calls unusable.
> 
> Instead of dropping packets when the L2TP socket isn't bound to a PPP
> channel, this patch adds them to its reception queue.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.
