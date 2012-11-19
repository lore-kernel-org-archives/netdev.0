From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [GIT PULL] Marvell Ethernet driver clk support + section mismatch fix
Date: Mon, 19 Nov 2012 15:13:14 +0100
Message-ID: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-arm-kernel@lists.infradead.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:38232 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab2KSONb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 09:13:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

Here are two additional patches for the mvneta Ethernet driver
(intended for your mvebu/driver branch):

 * One adding clk support. It's not a fix, but I think it's better if
   we can get the Device Tree binding correct directly in 3.8. This
   commit basically replaces the clock-frequency DT property by a
   proper 'clocks' DT property that references a DT clock. If we don't
   get this in 3.8, we'll have to support the legacy clock-frequency
   DT property for ever as it will be part of the kernel-to-DT ABI. So
   it would be nicer to get this patch in for 3.8.

   The DT patches related to this one are coming into a separate pull
   request.

 * The second one fixes a section mismatch warning, so it is certainly
   important.

Thanks!

The following changes since commit 803b4905545039f97c7824bcab605e91ac20acbb:

  Merge remote-tracking branch 'jcooper/mvebu/dt' into mvneta-fixes (2012-11-19 12:08:58 +0100)

are available in the git repository at:

  git@github.com:MISL-EBU-System-SW/mainline-public.git tags/marvell-mvneta-fix-and-clk-support-3.8

for you to fetch changes up to 4b968e8f98603a422f35b18682c169fb706c0115:

  net: mvneta: fix section mismatch warning caused by mvneta_deinit() (2012-11-19 14:45:25 +0100)

----------------------------------------------------------------
Marvell Ethernet driver fix + clk support

----------------------------------------------------------------
Thomas Petazzoni (2):
      net: mvneta: add clk support
      net: mvneta: fix section mismatch warning caused by mvneta_deinit()

 .../bindings/net/marvell-armada-370-neta.txt       |    4 +--
 drivers/net/ethernet/marvell/mvneta.c              |   33 +++++++++++++-------
 2 files changed, 23 insertions(+), 14 deletions(-)
