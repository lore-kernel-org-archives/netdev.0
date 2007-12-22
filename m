From: Bjorge Dijkstra <bjd@jooz.net>
Subject: [PATCH 0/8] RFC: Wireless Extensions for rndis_host
Date: Sat, 22 Dec 2007 22:51:26 +0100
Message-ID: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:23494 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754059AbXLVVvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 16:51:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I have here a patchset that needs some review.
This patchset adds wireless extensions for rndis_host to
enable support for RNDIS based USB wireless LAN adapters
(e.g. Linksys WUSB54GS, Belkin F05D7051).

In this patchset:
 1.  Fix sparse warning: returning void valued expression
 2.  Hardwire CDC descriptors when missing
 3.  Use 1KB buffer in rndis_unbind
 4.  Halt device if rndis_bind fails
 5.  Fix rndis packet filter flags
 6.  Split up rndis_host.c
 7.  Add Wireless Extensions for rndis_host
 8.  Use wlan device name for RNDIS wireless devices

The first five patches are more generic fixes that I think
can be applied as they are. Of these, patch 2 is required
to get these wireless devices working. 
Patches 6-8 introduce some larger changes that may need a
closer look.

All these patches should be applied in order.
The entire series should apply cleanly to current linux
kernel and net-2.6.25 trees.

regards,
Bjorge Dijkstra
