From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 0/10] ps3: fixes for ps3_gelic driver
Date: Fri, 20 Jul 2007 17:08:17 +0900
Message-ID: <20070720162345.6775.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:49322 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762228AbXGTIIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:08:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset are fixes and updates incorporating the comments from Jeff
Garzik and Stephen Hemminger.
Please accept the following patches for the ps3_gelic driver.  Thanks.

 [1] ps3: fix wrong calculation of rx descriptor address
 [2] ps3: some minor cleanups
 [3] ps3: tx descriptor handling cleanup
 [4] ps3: removed defines no longer used
 [5] ps3: removed conditional ethtool support
 [6] ps3: use net_device_stats of net_device structure
 [7] ps3: use ethX as the name of irq
 [8] ps3: removed calling netif_poll_enable() in open()
 [9] ps3: fix rare issue that reenabling rx DMA fails
[10] ps3: reduce allocation size of rx skb buffers


--
Masakazu MOKUNO

