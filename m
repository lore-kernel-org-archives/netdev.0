From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 0/4] net/macb: add sama5d2 support
Date: Thu, 18 Jun 2015 16:27:19 +0200
Message-ID: <cover.1434637286.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:20408 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbbFRO1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:27:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series is basically the support for another flavor of the GEM IP
configuration. It ended up being a series because of some little fixes made to
the binding documentation before adding the new compatibility string.

Bye,

v2: - fix bindings
    - add sama5d2 compatibility string to the binding documentation

Cyrille Pitchen (1):
  net/macb: add config for Atmel sama5d2 SoCs

Nicolas Ferre (3):
  net/macb: bindings doc: fix compatibility string
  net/macb: bindings doc/trivial: fix sama5d4 comment
  net/macb: bindings doc: add sama5d2 compatibility sting

 Documentation/devicetree/bindings/net/macb.txt | 5 +++--
 drivers/net/ethernet/cadence/macb.c            | 8 ++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

-- 
2.1.3
