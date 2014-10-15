From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 0/3] stmmac: review driver Koptions
Date: Wed, 15 Oct 2014 10:25:28 +0200
Message-ID: <1413361531-9182-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:55447 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbaJOIac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 04:30:32 -0400
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s9F8Sjsv011660
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 10:30:30 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1q10545xa5-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 10:30:30 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A26023C
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 08:30:06 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AB8D02CD58
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 08:30:28 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are to rework some Koption used for configuring
the driver. Recently many options have been added and the main
goal behind this work is to guarantee that the driver built fine
on all the branches where it is present. All the Koption for
platform drivers can be safely removed (for example never added
for SPEAr). In that case, it will be possible to validate the
build for all the platforms like STi avoiding failures.
The patches have been tested on STi Boxes w/o issue at runtime.

Giuseppe Cavallaro (3):
  stmmac: remove specific SoC Koption from platform.
  stmmac: remove STMMAC_DEBUG_FS
  stmmac: remove BUS_MODE_DA

 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   68 +------------------
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    8 +--
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    4 -
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    9 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   14 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   10 +---
 6 files changed, 16 insertions(+), 97 deletions(-)

-- 
1.7.4.4
