From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/4] au1000_eth platform device/driver conversion
Date: Tue, 28 Jul 2009 23:00:04 +0200
Message-ID: <200907282300.07144.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:47403 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbZG1VAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:00:17 -0400
Received: by ewy26 with SMTP id 26so359125ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:00:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ralf, David, Manuel,

The following patches convert the AMD Alchemy au1000_eth driver
to become a platform device/driver. The patches are splitted that way:

PATCH 1: set up the infrastructure in the board code to register au1000_eth as
as platform device.
PATCH 2: convert au1000_eth to become a real platform driver
PATCH 3: add infrastructure to pass PHY informations to the au1000_eth driver
PATCH 4: use those platform_data PHY informations in the au1000_eth driver

The result is a driver which is equally functionnal with no platform-related ifdefs
aiming towards easier integration of the upcoming Alchemy 1300 SoC. The conversion
was made in two times to ease code review as the driver was a real ifdef mess prior
to these changes.

David, on top of this series I send driver cleanups.

Thanks !
-- 
Best regards, Florian Fainelli
Email: florian@openwrt.org
Web: http://openwrt.org
IRC: [florian] on irc.freenode.net
-------------------------------
