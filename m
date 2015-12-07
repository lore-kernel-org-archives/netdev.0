From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net 0/2] Add a property to disable MACB USRIO register
Date: Mon,  7 Dec 2015 11:58:32 +0100
Message-ID: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchet introduces an optional DT property to disable usage of the
USRIO register on platform not implementing it thus avaiding some external
impresise aborts of ARM based platforms.

Neil Armstrong (2):
  net: cadence: macb: Disable USRIO register on some platforms
  bindings: net: macb: add no-usrio optional property

 Documentation/devicetree/bindings/net/macb.txt |  3 +++
 drivers/net/ethernet/cadence/macb.c            | 29 +++++++++++++++-----------
 2 files changed, 20 insertions(+), 12 deletions(-)

-- 
1.9.1
