From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Remove TCPCT
Date: Sun, 17 Mar 2013 14:35:48 -0400 (EDT)
Message-ID: <20130317.143548.1427926053702804045.davem@davemloft.net>
References: <1363544614-14411-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445Ab3CQSft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 14:35:49 -0400
In-Reply-To: <1363544614-14411-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sun, 17 Mar 2013 19:23:34 +0100

> TCPCT uses option-number 253, reserved for experimental use and should
> not be used in production environments.
> Further, TCPCT does not fully implement RFC 6013.
> 
> As a nice side-effect, removing TCPCT increases TCP's performance for
> very short flows:
> 
> Doing an apache-benchmark with -c 100 -n 100000, sending HTTP-requests
> for files of 1KB size.
> 
> before this patch:
> 	average (among 7 runs) of 20845.5 Requests/Second
> after:
> 	average (among 7 runs) of 21403.6 Requests/Second
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thanks Christoph.
