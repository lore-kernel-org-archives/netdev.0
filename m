From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 00/10] 6lowpan: pending patches
Date: Wed,  9 Dec 2015 22:17:06 +0100
Message-ID: <1449695836-13937-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35118 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbbLIVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:18:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

these are the current pending patches for 6lowpan based on bluetooth-next.
It contains the following new features:
 - per interface debugfs support, useful to add settings to offers a
   fast/simple userspace api for debugging.
 - register of available NHC compression by IANA, see [0].
 - Adding "ipv6_addr_prefix_copy" functionality for upcoming IPHC stateful
   compression.

- Alex

[0] https://www.iana.org/assignments/_6lowpan-parameters/_6lowpan-parameters.xhtml#lowpan_nhc

Alexander Aring (3):
  6lowpan: add lowpan dev register helpers
  6lowpan: add debugfs support
  ipv6: add ipv6_addr_prefix_copy

Stefan Schmidt (7):
  6lowpan: clarify Kconfig entries for upcoming GHC support
  6lowpan: add nhc module for GHC hop-by-hopextension header detection
  6lowpan: add nhc module for GHC UDP detection
  6lowpan: add nhc module for GHC ICMPv6 detection
  6lowpan: add nhc module for GHC destination extension header detection
  6lowpan: add nhc module for GHC fragmentation extension header
    detection
  6lowpan: add nhc module for GHC routing extension header detection

 include/net/6lowpan.h           | 10 ++++++-
 include/net/ipv6.h              | 15 +++++++++++
 net/6lowpan/6lowpan_i.h         | 28 +++++++++++++++++++
 net/6lowpan/Kconfig             | 47 ++++++++++++++++++++++++++++++--
 net/6lowpan/Makefile            |  9 +++++++
 net/6lowpan/core.c              | 59 +++++++++++++++++++++++++++++++++++++++--
 net/6lowpan/debugfs.c           | 53 ++++++++++++++++++++++++++++++++++++
 net/6lowpan/nhc_ghc_ext_dest.c  | 27 +++++++++++++++++++
 net/6lowpan/nhc_ghc_ext_frag.c  | 28 +++++++++++++++++++
 net/6lowpan/nhc_ghc_ext_hop.c   | 27 +++++++++++++++++++
 net/6lowpan/nhc_ghc_ext_route.c | 27 +++++++++++++++++++
 net/6lowpan/nhc_ghc_icmpv6.c    | 27 +++++++++++++++++++
 net/6lowpan/nhc_ghc_udp.c       | 27 +++++++++++++++++++
 net/bluetooth/6lowpan.c         |  8 +++---
 net/ieee802154/6lowpan/core.c   |  6 ++---
 15 files changed, 384 insertions(+), 14 deletions(-)
 create mode 100644 net/6lowpan/6lowpan_i.h
 create mode 100644 net/6lowpan/debugfs.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_dest.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_frag.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_hop.c
 create mode 100644 net/6lowpan/nhc_ghc_ext_route.c
 create mode 100644 net/6lowpan/nhc_ghc_icmpv6.c
 create mode 100644 net/6lowpan/nhc_ghc_udp.c

-- 
2.6.1
