From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/4] stmmac EEE fixes
Date: Tue, 26 Aug 2014 09:16:19 +0200
Message-ID: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47430 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755391AbaHZHQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:16:31 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q79l2f026747
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:29 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hrgs1y2-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:29 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 74B3A31
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:19 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9D913164E5
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:27 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a subset of patches to provide some fixes for the EEE support inside the
driver.
Patches have been tested on boards EEE capable plugged on switch w/ w/o EEE
support.

Giuseppe CAVALLARO (1):
  stmmac: never check EEE in case of a switch is attached

Giuseppe Cavallaro (1):
  stmmac: fix PLS bit setting when EEE is active

nandini sharma (2):
  stmmac: fix the EEE LPI Macro definitions.
  stmmac: fix LPI TW timer value to 20.5us.

 drivers/net/ethernet/stmicro/stmmac/common.h      |   10 +++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   12 ++++++++----
 2 files changed, 13 insertions(+), 9 deletions(-)

-- 
1.7.4.4
