From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3] net: phy: Create sysfs reciprocal links for attached_dev/phydev
Date: Thu, 25 May 2017 09:21:40 -0700
Message-ID: <20170525162143.18319-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36182 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165401AbdEYQVt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:21:49 -0400
Received: by mail-qt0-f196.google.com with SMTP id j13so30767326qta.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 09:21:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Andrew,

This patch series addresses a device topology shortcoming where a program
scanning /sys would not be able to establish a mapping between the network
device and the PHY device.

In the process it turned out that no PHY device documentation existed for
sysfs attributes.

Thanks!

Changes in v2:

- document possible phy_interface values in sysfs-class-net-phydev

Florian Fainelli (3):
  net: phy: Create sysfs reciprocal links for attached_dev/phydev
  net: sysfs: Document "phydev" symbolic link
  net: sysfs: Document PHY device sysfs attributes

 Documentation/ABI/testing/sysfs-class-net        |  8 ++++++
 Documentation/ABI/testing/sysfs-class-net-phydev | 36 ++++++++++++++++++++++++
 drivers/net/phy/phy_device.c                     | 11 ++++++++
 3 files changed, 55 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-phydev

-- 
2.9.3
