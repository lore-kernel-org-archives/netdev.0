From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/6] net: dsa: tagger simplification
Date: Tue, 30 May 2017 14:33:13 -0400
Message-ID: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset removes the unused arguments of the taggers rcv function
and the unneeded labels in their implementations, and handles freeing of
the original SKB in the xmit caller.

Changes in v2:
  - do not remove tagger function copies
  - document hot path requirements
  - make netdev_uses_dsa simpler
  - add reviewers' tags

Vivien Didelot (6):
  net: dsa: comment hot path requirements
  net: dsa: do not cast dst
  net: dsa: remove dsa_uses_tagged_protocol
  net: dsa: remove unused arguments of tagger rcv
  net: dsa: remove out_drop label in taggers rcv
  net: dsa: factor skb freeing on xmit

 include/net/dsa.h     | 15 +++++----------
 net/dsa/dsa.c         |  2 +-
 net/dsa/dsa2.c        |  2 +-
 net/dsa/dsa_priv.h    |  5 ++---
 net/dsa/legacy.c      |  2 +-
 net/dsa/slave.c       |  8 ++++++--
 net/dsa/tag_brcm.c    | 21 ++++++---------------
 net/dsa/tag_dsa.c     | 25 ++++++++-----------------
 net/dsa/tag_edsa.c    | 25 ++++++++-----------------
 net/dsa/tag_lan9303.c |  8 ++------
 net/dsa/tag_mtk.c     | 19 +++++--------------
 net/dsa/tag_qca.c     | 21 ++++++---------------
 net/dsa/tag_trailer.c | 17 +++++------------
 13 files changed, 56 insertions(+), 114 deletions(-)

-- 
2.13.0
