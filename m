From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: Fix setting a flag in
 br_fill_ifvlaninfo_range().
Date: Fri, 24 Jul 2015 22:57:55 -0700 (PDT)
Message-ID: <20150724.225755.745816746075981554.davem@davemloft.net>
References: <1437541022-14250-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbGYFoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:44:54 -0400
In-Reply-To: <1437541022-14250-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Wed, 22 Jul 2015 07:57:02 +0300

> This patch fixes setting of vinfo.flags in the br_fill_ifvlaninfo_range() method. The
> assignment of vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN has no effect and is
> unneeded, as vinfo.flags value is overriden by the  immediately following 
> vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END assignement.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied.
