From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: dont send notification when skb->len == 0 in
 rtnl_bridge_notify
Date: Tue, 27 Jan 2015 23:05:11 -0800 (PST)
Message-ID: <20150127.230511.1131199235284204820.davem@davemloft.net>
References: <1422423984-29743-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	rami.rosen@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbbA2ByG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:54:06 -0500
In-Reply-To: <1422423984-29743-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Tue, 27 Jan 2015 21:46:24 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Reported in: https://bugzilla.kernel.org/show_bug.cgi?id=92081
> 
> This patch avoids calling rtnl_notify if the device ndo_bridge_getlink
> handler does not return any bytes in the skb.
> 
> Alternately, the skb->len check can be moved inside rtnl_notify.
> 
> For the bridge vlan case described in 92081, there is also a fix needed
> in bridge driver to generate a proper notification. Will fix that in
> subsequent patch.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

This doesn't apply to the 'net' tree, is there something I missed?
