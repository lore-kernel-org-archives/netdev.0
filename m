From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] igb: do not use phy ops in ethtool test
 cleanup for non-copper parts
Date: Fri, 21 Nov 2008 21:30:33 -0800 (PST)
Message-ID: <20081121.213033.134929699.davem@davemloft.net>
References: <20081121235912.2150.53268.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751110AbYKVFae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:30:34 -0500
In-Reply-To: <20081121235912.2150.53268.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 15:59:12 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Currently the igb driver is experiencing a panic due to a null function
> pointer being used during the cleanup of the ethtool looback test on
> fiber/serdes parts.  This patch prevents that and adds a check prior to
> calling any phy function.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
