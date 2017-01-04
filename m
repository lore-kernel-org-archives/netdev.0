From: John Crispin <john@phrozen.org>
Subject: [RFC 0/4] net-next: dsa: add support for multiple cpu ports
Date: Wed,  4 Jan 2017 08:38:00 +0100
Message-ID: <1483515484-21793-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60159 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934397AbdADHiR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 02:38:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is based on work from Andrew. I have rebased his patches to
work on the latest kernel. The main problem is probably the fact that the
cpu port to user port mapping happens inside the devicetree.

Andrew Lunn (3):
  Documentation: devicetree: add multiple cpu port DSA binding
  net-next: dsa: Refactor DT probing of a switch port
  net-next: dsa: Add support for multiple cpu ports.

John Crispin (1):
  net-next: dsa: qca8k: add support for multiple cpu ports

 Documentation/devicetree/bindings/net/dsa/dsa.txt |   67 +++++++++-
 drivers/net/dsa/qca8k.c                           |  135 +++++++++++---------
 drivers/net/dsa/qca8k.h                           |    2 -
 include/net/dsa.h                                 |   21 +++-
 net/dsa/dsa.c                                     |  138 +++++++++++++++------
 net/dsa/dsa2.c                                    |   36 +++++-
 net/dsa/dsa_priv.h                                |    5 +
 net/dsa/slave.c                                   |   27 ++--
 8 files changed, 317 insertions(+), 114 deletions(-)

-- 
1.7.10.4
