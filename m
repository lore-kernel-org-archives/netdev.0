From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] inet: Fix kmemleak in tcp_v4/6_syn_recv_sock and
 dccp_v4/6_request_recv_sock
Date: Fri, 14 Dec 2012 13:16:54 -0500 (EST)
Message-ID: <20121214.131654.1860514296150221967.davem@davemloft.net>
References: <1355494078-7880-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	dccp@vger.kernel.org, eric.dumazet@gmail.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964Ab2LNSQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 13:16:56 -0500
In-Reply-To: <1355494078-7880-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Fri, 14 Dec 2012 15:07:58 +0100

> If in either of the above functions inet_csk_route_child_sock() or
> __inet_inherit_port() fails, the newsk will not be freed:
 ...
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable.
