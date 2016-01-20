From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v3 0/4] net: mvneta: support more than one clk
Date: Wed, 20 Jan 2016 19:27:21 +0800
Message-ID: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, devicetree@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides "core" clk for the mac core, and "axi"
clk for the AXI bus logic.

This series tries to addess the "more than one clk" issue. Note: to
support BG4CT, we have lots of refactor work to do, eg. BG4CT doesn't
have mbus concept etc.

Since v2:
 - Name the optional clock as "bus", which is a bit more flexible.

Since v1:
 - Add Thomas Acks to patch1 and patch2.
 - make sure the headers are really sorted (some headers are still
   unsorted in v1).
 - disable axi clk before disabling core clk, Thank Thomas.
 - update dt binding as Thomas suggested.


Jisheng Zhang (4):
  net: mvneta: sort the headers in alphabetic order
  net: mvneta: Try to get named core clock first
  net: mvneta: get optional bus clk
  net: mvneta: update clocks property and document additional
    clock-names

 .../bindings/net/marvell-armada-370-neta.txt       |  7 +++-
 drivers/net/ethernet/marvell/mvneta.c              | 38 ++++++++++++++--------
 2 files changed, 30 insertions(+), 15 deletions(-)

-- 
2.7.0.rc3
