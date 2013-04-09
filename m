From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 00/11] tg3: misc patches - minor fixes and
 enhancements
Date: Tue, 9 Apr 2013 11:48:00 -0700
Message-ID: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2278 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761628Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains minor fixes and enhancements (SGMII phy support and Link
Flap Avoidance). 

Michael Chan (3):
  tg3: Fix NVRAM size detection for the STM45PE20 pinstrap on 5762
    devices
  tg3: Add tg3_clear_mac_status() common function
  tg3: Add SGMII phy support for 5719/5718 serdes

Nithin Nayak Sujir (8):
  tg3: Fix flow control settings not propagated to hardware
  tg3: Remove unnecessary phy reset during ethtool commands
  tg3: Add a warning during link settings change if mgmt enabled
  tg3: Add support for link flap avoidance
  tg3: Pull the phy advertised speed and flow control settings on driver
    load
  tg3: Reset the phy to allow modified EEE settings to take effect
  tg3: Update version to 3.131
  MAINTAINERS: Update tg3 to reflect organizational changes

 MAINTAINERS                         |   2 +-
 drivers/net/ethernet/broadcom/tg3.c | 349 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/tg3.h |  12 ++
 3 files changed, 323 insertions(+), 40 deletions(-)

-- 
1.8.1.4
