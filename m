From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 00/21] ARCNET: Defibrillation
Date: Fri, 24 Apr 2015 19:20:34 +0200
Message-ID: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This patch series tries to reanimate the ARCNET hardware layer to be
somehow readable and maintainable again. It includes a lot of cleanup
patches. It also adds some fixes which leads the layer to become usable
again. And as a special treatment it adds more features like correct
loading and unloading of the com20020 card.

Cheers,
Michael

Michael Grzeschik (21):
  com20020-pci: add dev_port for udev handling
  ARCNET: fix hard_header_len limit
  ARCNET: capmode: fix transfer length
  ARCNET: whitespace, tab and codingstyle fixes
  ARCNET: remove unneeded macros
  ARCNET: com20020: remove unneeded macros
  ARCNET: rimi: remove unneeded macros
  ARCNET: com90io: remove unneeded macros
  ARCNET: com90xx: remove unneeded macros
  ARCNET: com20020: fix ioaddr prefixes
  ARCNET: rimi: fix ioaddr prefixes
  ARCNET: com90io: fix ioaddr prefixes
  ARCNET: com90xx: fix ioaddr prefixes
  ARCNET: arc-rawmode: reorder module functions
  ARCNET: capmode: remove extra function and use C99 in struct
  ARCNET: capmode: move dev_free_skb to its only user
  ARCNET: com20020: replace magic numbers with readable macros
  ARCNET: com20020: remove obsolete BUS_ALIGN offset factor
  ARCNET: com20020: add enable and disable device on open/close
  ARCNET: com20020-pci: reformat structs to C99 format
  ARCNET: com20020-pci: add rotary index support

 drivers/net/arcnet/arc-rawmode.c  |  91 +++++-------
 drivers/net/arcnet/arc-rimi.c     |  42 ++----
 drivers/net/arcnet/arcnet.c       | 192 +++++++++++-------------
 drivers/net/arcnet/capmode.c      |  32 ++--
 drivers/net/arcnet/com20020-isa.c |   4 +-
 drivers/net/arcnet/com20020-pci.c |  66 ++++++++-
 drivers/net/arcnet/com20020.c     | 152 +++++++++++--------
 drivers/net/arcnet/com20020_cs.c  | 302 ++++++++++++++++++--------------------
 drivers/net/arcnet/com90io.c      |  98 ++++++-------
 drivers/net/arcnet/com90xx.c      |  65 ++++----
 include/linux/arcdevice.h         |  15 +-
 include/linux/com20020.h          |  69 +++------
 include/uapi/linux/if_arcnet.h    |  48 +++---
 13 files changed, 572 insertions(+), 604 deletions(-)

-- 
2.1.4
