From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v2 0/4] net: mvneta: support more than one clk
Date: Wed, 20 Jan 2016 17:20:18 +0800
Message-ID: <1453281622-7829-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <sebastian.hesselbarth@gmail.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
	<mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides "core" clk for the mac core, and "axi"
clk for the AXI bus logic.

This series tries to addess the "more than one clk" issue. Note: to
support BG4CT, we have lots of refactor work to do, eg. BG4CT doesn't
have mbus concept etc.

Since v1:
 - Add Thomas Acks to patch1 and patch2.
 - make sure the headers are really sorted (some headers are still
   unsorted in v1).
 - disable axi clk before disabling core clk, Thank Thomas.
 - update dt binding as Thomas suggested.


Jisheng Zhang (4):
  net: mvneta: sort the headers in alphabetic order
  net: mvneta: Try to get named core clock first
  net: mvneta: get optional axi clk
  net: mvneta: update clocks property and document additional
    clock-names

 .../bindings/net/marvell-armada-370-neta.txt       |  7 +++-
 drivers/net/ethernet/marvell/mvneta.c              | 38 ++++++++++++++--------
 2 files changed, 30 insertions(+), 15 deletions(-)

-- 
2.7.0.rc3
