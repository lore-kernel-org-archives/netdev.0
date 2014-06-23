From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net 0/2] net: stmmac: Correct socfpga init/exit and cppcheck issue
Date: Sun, 22 Jun 2014 19:34:59 -0500
Message-ID: <1403483701-21199-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:48983 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaFWAi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:38:59 -0400
Received: by mail-ig0-f177.google.com with SMTP id c1so2369813igq.16
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 17:38:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds platform specific init/exit code so that socfpga
suspend/resume works as expected, and corrects a minor issue detected by
cppcheck. 

Vince Bridgers (2):
  net: stmmac: add platform init/exit for Altera's ARM socfpga
  net: stmmac: Correct duplicate if/then/else case found by cppcheck

 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   68 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 ++
 3 files changed, 73 insertions(+), 1 deletion(-)

-- 
1.7.9.5
