From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Mon, 24 Oct 2011 03:01:45 -0400 (EDT)
Message-ID: <20111024.030145.705404671921819890.davem@davemloft.net>
References: <4EA3C91C.3090801@intel.com>
	<alpine.LFD.2.00.1110231533410.1499@ja.ssi.bg>
	<4EA4B451.7010708@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	kim.phillips@freescale.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab1JXHCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 03:02:01 -0400
In-Reply-To: <4EA4B451.7010708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Mon, 24 Oct 2011 08:41:53 +0800

> My understanding is that xfrm_dst(s) are managed by the flow cache
> (net/core/flow.c). We don't put them into the routing cache.

This is correct.
