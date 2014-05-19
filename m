From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] broadcom drivers and fixed-link doc updates
Date: Mon, 19 May 2014 12:43:41 -0700
Message-ID: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45626 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525AbaESTpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 15:45:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Thomas,

This patch series converts GENET and SYSTEMPORT to use the new fixed PHY
OF helpers and progressively get rid of of_phy_connect_fixed_link().

The second part of the patch set makes sure that we document the old 5-digit
fixed-link property in a central location and update all current users to
refer to it.

Thanks!

Florian Fainelli (4):
  net: bcmgenet: use the new fixed PHY helpers
  net: systemport: use the new fixed PHY helpers
  Documentation: devicetree: add old and deprecated 'fixed-link'
  Documentation: devicetree: net: refer to fixed-link.txt

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  2 +-
 .../bindings/net/broadcom-systemport.txt           |  2 +-
 .../devicetree/bindings/net/fixed-link.txt         |  7 +++++++
 .../devicetree/bindings/net/fsl-tsec-phy.txt       |  5 +----
 drivers/net/ethernet/broadcom/bcmsysport.c         | 18 ++++++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h         |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 22 ++++++++++++++--------
 7 files changed, 41 insertions(+), 16 deletions(-)

-- 
1.9.1
