From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 22 May 2006 15:19:42 -0400
Message-ID: <20060522191942.GE13964@tuxdriver.com>
References: <20060522191759.GD13964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:17171 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751145AbWEVTTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 15:19:49 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060522191759.GD13964@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 01d654d25d23fb73deb7904ce1c0b3a0f5fc2908:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Marcin Juszkiewicz:
      hostap: new pcmcia IDs

 drivers/net/wireless/hostap/hostap_cs.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 55bed92..db03dc2 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -881,6 +881,12 @@ static struct pcmcia_device_id hostap_cs
 	PCMCIA_DEVICE_PROD_ID12(
 		"ZoomAir 11Mbps High", "Rate wireless Networking",
 		0x273fe3db, 0x32a1eaee),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Pretec", "CompactWLAN Card 802.11b", "2.5",
+		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
+	PCMCIA_DEVICE_PROD_ID123(
+		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
+		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
-- 
John W. Linville
linville@tuxdriver.com
