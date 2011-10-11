From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 0/5] stmmac: update to Oct 2011 version
Date: Tue, 11 Oct 2011 09:30:41 +0200
Message-ID: <1318318246-1326-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:50071 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750776Ab1JKHbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 03:31:03 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0A42ED3
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:30:53 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 87E971A8B
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 07:30:53 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches update the driver adding the chained
descriptor mode and some new useful fixes.

Giuseppe Cavallaro (3):
  stmmac: allow mtu bigger than 1500 in case of normal desc.
  stmmac: protect tx process with lock
  stmmac: update the driver version and doc

Rayagond Kokatanur (1):
  stmmac: add CHAINED descriptor mode support

Srinivas Kandagatla (1):
  stmmac: Stop advertising 1000Base capabilties for non GMII iface
    (v2).

 Documentation/networking/stmmac.txt               |   11 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |   18 +++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   24 +++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   27 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  163 ++++++++++++++++++---
 6 files changed, 213 insertions(+), 33 deletions(-)

-- 
1.7.4.4
