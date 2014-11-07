From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv4 0/1] net: fec: fix regression on i.MX28 introduced by rx_copybreak support
Date: Fri,  7 Nov 2014 10:02:46 +0100
Message-ID: <1415350967-2238-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58808 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaKGJEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 04:04:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes wrt. v1:
- added some cleanup patches
- simplify handling of 'quirks' flags as suggested by Russell King.
- remove DIV_ROUND_UP() from byte swapping loop as suggested by
  Eric Dumazet

Changes wrt. v2:
- rebased against next-20141028
- added some more cleanups in fec.h
- removed unused return value from swap_buffer()
- fixed messed swab32s() call in swap_buffer2()
- fixed messed up setup of fep->quirks

Changes wrt. v3:
- removed the cleanup patches; will send later to net-next,
  when the bugfix patch has been applied
