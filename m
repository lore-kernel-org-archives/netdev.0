From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 0/4] uapi: consolidate DIV_ROUND_UP definition
Date: Fri,  4 Mar 2016 11:52:15 +0100
Message-ID: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49053 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbcCDKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:52:48 -0500
In-Reply-To: <20160303.170804.2300821465150459193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The inital goal was to consolidate ethtool.h uapi header. But I took the
opportunity to remove all duplicate definitions of DIV_ROUND_UP.

v3: add patch #2 and #3

v2: split the patch
    define DIV_ROUND_UP in uapi

 .../drm/vmwgfx/device_include/svga3d_surfacedefs.h   | 20 +++++++++++---------
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                   |  2 +-
 include/linux/kernel.h                               |  2 +-
 include/uapi/linux/ethtool.h                         |  7 ++++++-
 include/uapi/linux/kernel.h                          |  1 +
 include/uapi/linux/mroute6.h                         |  9 ++-------
 6 files changed, 22 insertions(+), 19 deletions(-)

Regards,
Nicolas
