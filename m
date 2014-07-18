From: Neil Armstrong <superna9999@gmail.com>
Subject: [PATCH 0/2] net: macb: Handle RX errors
Date: Fri, 18 Jul 2014 11:51:35 +0200
Message-ID: <53C8EE27.3060201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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

Neil Armstrong (2):
  net: macb: Separate rx and tx ring init function
  net: macb: Handle errors in RX path

 drivers/net/ethernet/cadence/macb.c |   88 +++++++++++++++++++++++++++++------
 drivers/net/ethernet/cadence/macb.h |    3 +-
 2 files changed, 76 insertions(+), 15 deletions(-)
