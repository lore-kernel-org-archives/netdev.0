From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 00/36] bnx2x patch series
Date: Wed, 12 Aug 2009 21:19:22 +0300
Message-ID: <1250101162.27379.151.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Yitchak Gertner" <gertner@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2809 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbZHLSUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here is a patch series for the bnx2x. This patch series also replace the
FW, so
it contains two big blobs - the new fw and the removal of the old one.
Those
patches do not contain anything but the ihex - the actually change to
the driver
is in patch number 2 which is small enough to fit the mailing list.

For those who wish to see all the patches, including the ihex, I also
updated
http://linux.broadcom.com/eilong/ to contain this patch series.

Please consider applying to net-next.

Thanks,
Eilon

 drivers/net/Kconfig                 |    1 +
 drivers/net/bnx2x.h                 |  125 +-
 drivers/net/bnx2x_dump.h            |  890 ++--
 drivers/net/bnx2x_fw_defs.h         |  379 +-
 drivers/net/bnx2x_hsi.h             |  395 +-
 drivers/net/bnx2x_init.h            |  320 +-
 drivers/net/bnx2x_init_ops.h        |  419 +-
 drivers/net/bnx2x_link.c            | 1528 +++--
 drivers/net/bnx2x_link.h            |   49 +-
 drivers/net/bnx2x_main.c            | 2058 ++++---
 drivers/net/bnx2x_reg.h             | 1032 +---
 firmware/Makefile                   |    2 +-
 firmware/bnx2x-e1-4.8.53.0.fw.ihex  |10364 ----------------------------
 firmware/bnx2x-e1-5.0.21.0.fw.ihex  |10184 +++++++++++++++++++++++++++
 firmware/bnx2x-e1h-4.8.53.0.fw.ihex |12028
--------------------------------
 firmware/bnx2x-e1h-5.0.21.0.fw.ihex |12855
+++++++++++++++++++++++++++++++++++
 16 files changed, 26764 insertions(+), 25865 deletions(-)



