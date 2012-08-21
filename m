From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Use newinet->inet_opt in
 inet_csk_route_child_sock()
Date: Tue, 21 Aug 2012 14:49:47 -0700 (PDT)
Message-ID: <20120821.144947.2102823805754391660.davem@davemloft.net>
References: <1345467129-4540-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758608Ab2HUVts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 17:49:48 -0400
In-Reply-To: <1345467129-4540-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Mon, 20 Aug 2012 14:52:09 +0200

> Since 0e734419923bd ("ipv4: Use inet_csk_route_child_sock() in DCCP and
> TCP."), inet_csk_route_child_sock() is called instead of
> inet_csk_route_req().
> 
> However, after creating the child-sock in tcp/dccp_v4_syn_recv_sock(),
> ireq->opt is set to NULL, before calling inet_csk_route_child_sock().
> Thus, inside inet_csk_route_child_sock() opt is always NULL and the
> SRR-options are not respected anymore.
> Packets sent by the server won't have the correct destination-IP.
> 
> This patch fixes it by accessing newinet->inet_opt instead of ireq->opt
> inside inet_csk_route_child_sock().
> 
> Reported-by: Luca Boccassi <luca.boccassi@gmail.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thanks.
