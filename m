From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 0/5] Blackfin MAC updates for 2.6.31
Date: Wed, 27 May 2009 02:10:10 -0400
Message-ID: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32873 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759028AbZE0GKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:10:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fixes and MII lovin galore.

Graf Yang (2):
  netdev: bfin_mac: add Blackfin MII bus to platform bus to allow DSA
    access
  netdev: bfin_mac: fix crash when unloading module

Michael Hennerich (2):
  netdev: bfin_mac: Blackfin EMAC interrupt may not be shared
  netdev: bfin_mac: fix performance issue found by netperf

Sonic Zhang (1):
  netdev: bfin_mac: fix malformed UDP packet transmission when polling
    with KGDB

 drivers/net/bfin_mac.c |  232 +++++++++++++++++++++++------------------------
 1 files changed, 114 insertions(+), 118 deletions(-)

