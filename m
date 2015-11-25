From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH 0/2] Basic support for Solarflare 8000 series NICs
Date: Wed, 25 Nov 2015 16:04:40 +0000
Message-ID: <5655DC18.7090208@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:51573 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751684AbbKYQPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:15:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upcoming Solarflare 8000 series 10G/40G network card supports a 
similar interface to the current 7000 series cards. This patch series 
provides basic support for these cards, making no use of any new 
functionality.

Bert Kenward (2):
  sfc: make TSO version a per-queue parameter
  sfc: Add PCI ID for Solarflare 8000 series 10/40G NIC.

 drivers/net/ethernet/sfc/ef10.c       | 13 ++++++-------
 drivers/net/ethernet/sfc/efx.c        |  6 ++++++
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/tx.c         |  8 ++++++--
 4 files changed, 20 insertions(+), 9 deletions(-)

-- 
2.4.3
