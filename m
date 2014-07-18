From: Neil Armstrong <narmstrong@neotion.com>
Subject: [PATCH v2 0/2] net: macb: Handle RX errors
Date: Fri, 18 Jul 2014 14:42:59 +0200
Message-ID: <53C91653.5030105@neotion.com>
Reply-To: narmstrong@neotion.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On our hardware, the MACB connected to a heavilly used AXI bus, fails to
correctly write RX descriptors.

This leds to RX ring errors that can be managed.

These patchs add RX error management according to the Cadence MACB User Guide.

The first patch separates the RX and TX rings init in order to reuse the RX ring init.

v2: fix multiple assignments in first patch, fix checkpatch errors in second patch.

Neil Armstrong (2):
  net: macb: Separate rx and tx ring init function
  net: macb: Handle errors in RX path

 drivers/net/ethernet/cadence/macb.c |   90 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/cadence/macb.h |    3 +-
 2 files changed, 78 insertions(+), 15 deletions(-)
