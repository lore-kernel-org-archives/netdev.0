From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 00/15] drivers/net: Use (pr|netdev|netif)_<level> macros
Date: Wed, 17 Feb 2010 17:01:47 -0800
Message-ID: <cover.1266454575.git.joe@perches.com>
Cc: Gary Zambrano <zambrano@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	David Dillow <dave@thedillows.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1049 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755322Ab0BRBCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the newly added netdev_<level> and netif_<level> logging macros
in some of the drivers.

Adds some message logging consistency.

pci-skeleton had a checkpatch style cleaning as well.

Joe Perches (15):
  drivers/net/8139cp.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/8139too.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/b44.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/bnx2.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/bnx2x: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/cassini.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/cnic.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/pci-skeleton.c: Use (pr|netdev|netif)_<level> macro
    helpers
  drivers/net/sis190.c: Use (pr|netdev|netif)_<level> macro helpers
  drivers/net/skge.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/skge.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/sky2.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/tg3.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/typhoon.c: Use (pr|netdev)_<level> macro helpers
  drivers/net/yellowfin.c: Use (pr|netdev)_<level> macro helpers

 drivers/net/8139cp.c       |   72 ++--
 drivers/net/8139too.c      |  187 ++++-----
 drivers/net/b44.c          |   72 ++--
 drivers/net/bnx2.c         |  145 +++----
 drivers/net/bnx2x.h        |   49 ++-
 drivers/net/bnx2x_link.c   |   21 +-
 drivers/net/bnx2x_main.c   |  185 ++++-----
 drivers/net/cassini.c      |  361 +++++++---------
 drivers/net/cnic.c         |   87 ++---
 drivers/net/pci-skeleton.c | 1019 ++++++++++++++++++++++----------------------
 drivers/net/sis190.c       |  152 ++++----
 drivers/net/skge.c         |  131 +++---
 drivers/net/sky2.c         |   63 ++--
 drivers/net/tg3.c          |  261 +++++-------
 drivers/net/typhoon.c      |  162 ++++----
 drivers/net/yellowfin.c    |  162 ++++----
 16 files changed, 1431 insertions(+), 1698 deletions(-)

