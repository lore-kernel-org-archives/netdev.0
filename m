From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/2] Document and use eeprom-length property
Date: Fri, 26 May 2017 01:44:42 +0200
Message-ID: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        linux ARM <linux-arm-kernel@lists.infradead.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>, shawnguo@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45163 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933514AbdEYXpp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6xxx switch driver allows the size of the attached EEPROM to
be described in DT. This property is missing from the binding
documentation. Add it. And make use of it on the ZII Devel B board.

David, Shawn, please could you talk amongs yourself to decide who
takes what.

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Add eeprom-length to binding
  ARM: VF610: ZII devel b: Add switch eeprom-length properties

 Documentation/devicetree/bindings/net/dsa/marvell.txt | 4 ++++
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts             | 2 ++
 2 files changed, 6 insertions(+)

-- 
2.11.0
