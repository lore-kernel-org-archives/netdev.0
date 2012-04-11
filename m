From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/8] r6040: misc cleanups
Date: Wed, 11 Apr 2012 19:18:35 +0200
Message-ID: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45798 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760774Ab2DKRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series contains some cleanups and one small fix, they are targetted
at net-next.

Thanks!

Florian Fainelli (8):
  r6040: consolidate MAC reset to its own function
  r6040: remove unused variable mcr1 from private structure
  r6040: add a MAC operation timeout define
  r6040: fix typo on stats update in tx path
  r6040: define and use MLSR register bits
  r6040: define and use MTPR transmit enable bit
  r6040: define and use bits of register PHY_CC
  r6040: update copyright from 2007 to now

 drivers/net/ethernet/rdc/r6040.c |   75 ++++++++++++++++++++++----------------
 1 files changed, 44 insertions(+), 31 deletions(-)

-- 
1.7.5.4
