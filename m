From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] be2net: cleanup code related to
 be_link_status_query()
Date: Sun, 30 Sep 2012 02:16:16 -0400 (EDT)
Message-ID: <20120930.021616.2300886737245762860.davem@davemloft.net>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
	<851da7da-1e96-4aed-97f1-1207d73f9cf6@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab2I3GQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:16:17 -0400
In-Reply-To: <851da7da-1e96-4aed-97f1-1207d73f9cf6@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 28 Sep 2012 20:09:43 +0530

> 1) link_status_query() is always called to query the link-speed (speed
> after applying qos). When there is no qos setting, link-speed is derived from
> port-speed. Do all this inside this routine and hide this from the callers.
> 
> 2) adpater->phy.forced_port_speed is not being set anywhere after being
> initialized. Get rid of this variable.
> 
> 3) Ignore async link_speed notifications till the initial value has been
> fetched from FW.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
