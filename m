From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 0/2] net: dsa: integration with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 11:26:34 -0800
Message-ID: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33343 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbBQT1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 14:27:34 -0500
Received: by pabkx10 with SMTP id kx10so8511318pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 11:27:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset is mostly to demonstrate how we could integrate with SWITCHDEV
to provide HW bridging support for DSA switch drivers that are currently in
tree. Since 'net-next' is currently closed, this gives us some time to work
on the abstraction we want to have in DSA to facilitate our life.

Attached is an example of how this winds up looking like for the bcm_sf2 driver.

Florian Fainelli (2):
  net: dsa: integrate with SWITCHDEV for HW bridging
  net: dsa: bcm_sf2: implement HW bridging operations

 drivers/net/dsa/bcm_sf2.c |  93 ++++++++++++++++++++++++++++++++++++
 include/net/dsa.h         |  10 ++++
 net/dsa/Kconfig           |   1 +
 net/dsa/dsa.c             |   7 +++
 net/dsa/dsa_priv.h        |   2 +
 net/dsa/slave.c           | 117 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 230 insertions(+)

-- 
2.1.0
