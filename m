From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/5] Don't return NULL from get_phy_device() anymore
Date: Sun, 24 Apr 2016 20:23:03 +0300
Message-ID: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33533 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbcDXRXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:23:08 -0400
Received: by mail-lf0-f48.google.com with SMTP id y84so8047363lfc.0
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:23:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's the set of 5 patches against DaveM's 'net-next.git' repo. The first
patch makes get_phy_device() return only error values on error, the rest of
the patches clean up the callers of that function...

[1/5] phylib-don-t-return-NULL-from-get_phy_device.patch
[2/5] xgene-get_phy_device-doesn-t-return-NULL-anymore.patch
[3/5] fixed_phy-get_phy_device-doesn-t-return-NULL-anymore.patch
[4/5] mdio_bus-get_phy_device-doesn-t-return-NULL-anymore.patch
[5/5] of_mdio-get_phy_device-doesn-t-return-NULL-anymore.patch

MBR, Sergei
