From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 net-next 0/3] Add new capability and parse from DT
Date: Tue,  8 Dec 2015 14:52:03 +0100
Message-ID: <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org, joshc@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch introduces a new capability bit to disable usage of the
USRIO register on platform not implementing it thus avoiding some external
imprecise aborts on ARM based platforms.
The two last patchs implements a DT fallback to get the software defined 
capabilities from DT in the case of the generic compatible form is used.
These properties will permit support of future implementations of macb/gem
without the need for adding new static structures in the code.

v1: http://lkml.kernel.org/r/1449485914-12883-1-git-send-email-narmstrong@baylibre.com
v2: switch to CAPS_* bit and add all software CAPS_* as DT properties

Neil Armstrong (3):
  net: ethernet: cadence-macb: Add disabled usrio caps
  net: ethernet: cadence-macb: Add fallback to read DT provided caps
  bindings: ethernet: macb: Add optional caps properties

 Documentation/devicetree/bindings/net/macb.txt | 10 ++++
 drivers/net/ethernet/cadence/macb.c            | 72 +++++++++++++++++++++-----
 drivers/net/ethernet/cadence/macb.h            |  1 +
 3 files changed, 71 insertions(+), 12 deletions(-)

-- 
1.9.1
