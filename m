From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] ipvs: Bind connections on stanby if the
 destination exists
Date: Wed, 07 Nov 2007 02:36:08 -0800 (PST)
Message-ID: <20071107.023608.130104821.davem@davemloft.net>
References: <20071105030851.615630269@vergenet.net>
	<20071105030958.596331811@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org,
	rumen@voicecho.com, graeme@graemef.net, jmack@wm7d.net, ja@ssi.bg,
	wensong@linux-vs.org
To: horms@vergenet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753752AbXKGKgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:36:09 -0500
In-Reply-To: <20071105030958.596331811@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: horms@vergenet.net
Date: Mon, 05 Nov 2007 12:08:52 +0900

> From: Rumen G. Bogdanovski <rumen@voicecho.com>
> 
> This patch fixes the problem with node overload on director fail-over.
> Given the scenario: 2 nodes each accepting 3 connections at a time and 2
> directors, director failover occurs when the nodes are fully loaded (6
> connections to the cluster) in this case the new director will assign
> another 6 connections to the cluster, If the same real servers exist
> there.
 ...
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
