From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: do not ignore netdev errors when creating
 tunnel vports
Date: Wed, 10 Aug 2016 23:14:04 -0700 (PDT)
Message-ID: <20160810.231404.72331184301113017.davem@davemloft.net>
References: <20160809152450.6626-1-martynas@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: martynas@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbcHKGOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 02:14:05 -0400
In-Reply-To: <20160809152450.6626-1-martynas@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martynas Pumputis <martynas@weave.works>
Date: Tue,  9 Aug 2016 16:24:50 +0100

> The creation of a tunnel vport (geneve, gre, vxlan) brings up a
> corresponding netdev, a multi-step operation which can fail.
> 
> For example, changing a vxlan vport's netdev state to 'up' binds the
> vport's socket to a UDP port - if the binding fails (e.g. due to the
> port being in use), the error is currently ignored giving the
> appearance that the tunnel vport creation completed successfully.
> 
> Signed-off-by: Martynas Pumputis <martynas@weave.works>

Applied.
