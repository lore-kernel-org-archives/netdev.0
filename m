From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: phy: Create sysfs reciprocal links for attached_dev/phydev
Date: Wed, 24 May 2017 12:33:51 -0700
Message-ID: <20170524193354.10739-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33675 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030907AbdEXTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:34:04 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so10683746wrc.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 12:34:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Andrew,

This patch series addresses a device topology shortcoming where a program
scanning /sys would not be able to establish a mapping between the network
device and the PHY device.

In the process it turned out that no PHY device documentation existed for
sysfs attributes.

Thanks!

Florian Fainelli (3):
  net: phy: Create sysfs reciprocal links for attached_dev/phydev
  net: sysfs: Document "phydev" symbolic link
  net: sysfs: Document PHY device sysfs attributes

 Documentation/ABI/testing/sysfs-class-net        |  8 ++++++
 Documentation/ABI/testing/sysfs-class-net-phydev | 32 ++++++++++++++++++++++++
 drivers/net/phy/phy_device.c                     | 11 ++++++++
 3 files changed, 51 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-phydev

-- 
2.9.3
