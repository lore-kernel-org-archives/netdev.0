From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] FEC driver: patches for -next
Date: Wed, 15 Apr 2009 13:32:13 +0200
Message-ID: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37828 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758221AbZDOLc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These patches aim to modernize the FEC ethernet driver.
Greg, can you please confirm that the ifdef in patch 01/12 is indeed unused?

Sascha

The following changes since commit 0882e8dd3aad33eca41696d463bb896e6c8817eb:
  Linus Torvalds (1):
        Linux 2.6.30-rc2

are available in the git repository at:

  git://git.pengutronix.de/git/sha/linux-2.6.git fec

Sascha Hauer (12):
      fec: remove unused ifdef
      fec: switch to writel/readl
      fec: do not typedef struct types
      fec: remove unnecessary cast
      fec: Codingstyle cleanups
      fec: refactor set_multicast_list() to make it more readable
      fec: refactor init function
      fec: align receive packets
      fec: remove debugging printks
      fec: switch to net_device_ops
      FEC Buffer rework
      fec: call fec_restart() in fec_open()

 drivers/net/fec.c |  897 ++++++++++++++++++++++-------------------------------
 drivers/net/fec.h |  112 ++-----
 2 files changed, 402 insertions(+), 607 deletions(-)
