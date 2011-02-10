From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 0/3] Net driver fixes related to power management
Date: Thu, 10 Feb 2011 17:51:56 +0100
Message-ID: <201102101751.56508.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Linux PM mailing list <linux-pm@lists.linux-foundation.org>,
	Thomas Fjellstrom <thomas@fjellstrom.ca>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33487 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756602Ab1BJQ4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 11:56:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following series of patches fix minor issues related to power management
in the tg3, alt1 and atl1c drivers.

[1/3] - tg3: Don't use device_init_wakeup() (PCI does that)
[2/3] - atl1c: Don't use device_init_wakeup() (ditto)
[3/3] - atl1: Don't use legacy PCI power management.

Please consider for applying.

Thanks,
Rafael

