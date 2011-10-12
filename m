From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 0/5] stmmac: update to Oct 2011 version (V2)
Date: Wed, 12 Oct 2011 15:38:03 +0200
Message-ID: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:58211 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753053Ab1JLNiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 09:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches update the driver adding the chained
descriptor mode and some new useful fixes.
Chained / Ring modes have been reworked after D. Miller
advice and removing the ifdef selection within the C
code.

Giuseppe Cavallaro (4):
  stmmac: add CHAINED descriptor mode support
  stmmac: allow mtu bigger than 1500 in case of normal desc.
  stmmac: protect tx process with lock
  stmmac: update the driver version and doc

Srinivas Kandagatla (1):
  stmmac: Stop advertising 1000Base capabilties for non GMII iface
    (v2).

 Documentation/networking/stmmac.txt               |   11 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 +
 drivers/net/ethernet/stmicro/stmmac/common.h      |   19 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   51 ---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   42 --
 drivers/net/ethernet/stmicro/stmmac/ring_mode.h   |  450 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  148 +++----
 8 files changed, 564 insertions(+), 178 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/ring_mode.h

-- 
1.7.4.4
