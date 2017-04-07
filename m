From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: dsa: Receive path simplifications
Date: Fri,  7 Apr 2017 13:41:51 -0700
Message-ID: <20170407204154.9651-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35993 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdDGUmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:42:03 -0400
Received: by mail-qt0-f195.google.com with SMTP id v3so2915904qtd.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 13:42:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series does factor the common code found in all tag implementations
into dsa_switch_rcv(). The original motivation was to add GRO support, but this
may be a lot of work with unclear benefits at this point.

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
 net/dsa/tag_qca.c     | 26 +++++---------------------
 net/dsa/tag_trailer.c | 25 +++++--------------------
 8 files changed, 52 insertions(+), 108 deletions(-)

-- 
2.9.3
