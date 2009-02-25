From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/4] mv643xx_eth updates/fixes
Date: Wed, 25 Feb 2009 02:41:25 +0100
Message-ID: <20090225014125.GV17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53043 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbZBYBl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:41:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this series:
1. Make LRO unconditional.
2. Convert to net_device_ops.
3. Fix bugs where link status is not accurately reported via ethtool
   before the interface is up'd for the first time, and where rx/tx
   coalescing timers are reset to zero every time you up the interface.
4. Set a sane default rx coalescing value.

Please consider for 2.6.30.  Thanks. :-)
