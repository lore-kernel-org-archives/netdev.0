From: Neil Horman <nhorman@tuxdriver.com>
Subject: net: enable dynamic lro disabling for vlans
Date: Tue, 24 May 2011 13:15:12 -0400
Message-ID: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55834 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab1EXRP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:15:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey there-
	Noted recently that, while physical devices have lro disabled when
attached to a bridge, vlan devices do not.  This is because the vlan netdev has
no get/set flags method in its ethtool_ops struct. This series adds those
methods as passthrough calls to the underlying physical devices, so that whe
dev_disable_lro is called on a vlan device, the physical device underneath has
lro properly disabled.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: davem@davemloft.net

