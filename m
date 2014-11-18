From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 0/3] stmmac: update driver documentation
Date: Tue, 18 Nov 2014 09:46:58 +0100
Message-ID: <1416300421-25500-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33641 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753104AbaKRJD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 04:03:27 -0500
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sAI8ubq6029926
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:26 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1qqxcsh6dd-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:03:26 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 946D34A
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:02:48 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9BA4F2C9DF
	for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 09:03:18 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently many changes have been done inside the driver
so this patch updates the driver's doc for example reviewing
information for the rx and tx processes that are managed
by napi method, adding new information for missing glue-logic files
etc.
Also this reviews and fixes what is reported when run kernel-doc script.

Giuseppe Cavallaro (3):
  stmmac: update driver documentation
  stmmac: document common header file
  stmmac: review driver when run kernel-doc

 Documentation/networking/stmmac.txt                |  132 +++++++++---------
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |   15 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  151 +++++++++++++-------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   43 +++++-
 6 files changed, 215 insertions(+), 136 deletions(-)

-- 
1.7.4.4
