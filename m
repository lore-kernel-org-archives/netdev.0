From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3] net: dsa: Receive path simplifications
Date: Sat,  8 Apr 2017 08:55:20 -0700
Message-ID: <20170408155523.20447-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35325 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdDHPz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:55:29 -0400
Received: by mail-it0-f68.google.com with SMTP id y18so1610067itc.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 08:55:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series does factor the common code found in all tag implementations
into dsa_switch_rcv(). The original motivation was to add GRO support, but this
may be a lot of work with unclear benefits at this point.

Changes in v2:
- take care of tag_mtk.c in the process

Florian Fainelli (3):
  net: dsa: Do not check for NULL dst in tag parsers
  net: dsa: Move skb_unshare() to dsa_switch_rcv()
  net: dsa: Factor bottom tag receive functions

 include/net/dsa.h     |  2 +-
 net/dsa/dsa.c         | 24 +++++++++++++++++++++++-
 net/dsa/dsa_priv.h    |  5 +++--
 net/dsa/tag_brcm.c    | 26 +++++---------------------
 net/dsa/tag_dsa.c     | 26 +++++---------------------
 net/dsa/tag_edsa.c    | 26 +++++---------------------
 net/dsa/tag_mtk.c     | 28 +++++-----------------------
 net/dsa/tag_qca.c     | 26 +++++---------------------
 net/dsa/tag_trailer.c | 25 +++++--------------------
 9 files changed, 57 insertions(+), 131 deletions(-)

-- 
2.9.3
