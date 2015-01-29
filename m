From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bridge: dont send notification when skb->len == 0
 in rtnl_bridge_notify
Date: Wed, 28 Jan 2015 22:22:28 -0800 (PST)
Message-ID: <20150128.222228.633694287669808879.davem@davemloft.net>
References: <1422490991-4033-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	rami.rosen@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823AbbA2GtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 01:49:12 -0500
In-Reply-To: <1422490991-4033-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Wed, 28 Jan 2015 16:23:11 -0800

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
> v2: rebase patch on net tree
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
