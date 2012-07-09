From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 0/2] stmmac: nfs reboot crash & jumbo frame handling fix
Date: Mon, 9 Jul 2012 12:44:44 +0530
Message-ID: <1341818086-28897-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear--sw-devel@codex.cro.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:56953 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752266Ab2GIHOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:14:53 -0400
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 3F3009D
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2012 07:06:30 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set handles in the fixes for following bugs that were
observed during testing.
1. On Multiple reboot operations using nfs, system crash were observed
with inconsistency in status of dma descriptors.
2. There were data losses observed whenever the jumbo frames were used
for data transfers.

Deepak Sikri (2):
  stmmac: Fix for nfs hang on multiple reboot
  stmmac: Fix for higher mtu size handling

 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 +++
 2 files changed, 5 insertions(+), 1 deletions(-)

-- 
1.7.2.2
