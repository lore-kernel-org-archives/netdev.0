From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 0/4] Use new PCI PM code for Wake-on-LAN in some drivers
Date: Sat, 19 Jul 2008 14:36:39 +0200
Message-ID: <200807191436.40726.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44358 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037AbYGSMmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 08:42:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following series of patches adapts some PCI LAN drivers to use the new core
PCI wake-up code for Wake-on-LAN.  The following drivers are modified:

skge (tested on Asus L5D)
tg3 (tested on HP nx6325)
sky2 (tested on a desktop with the Asus M3A32-MVP mainboard)

The patches are on top of the current mainline.

Thanks,
Rafael

