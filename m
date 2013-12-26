From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH RFC v2 0/3] Add ethernet support for r7s72100
Date: Thu, 26 Dec 2013 23:04:48 +0900
Message-ID: <1388066691-5854-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
 Magnus Damm <magnus.damm@gmail.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
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

Hi,

this is a second pass at adding ethernet support to sh-pfc for
the r7s72100 SoC.

It has been written with reference to the hardware documentation
but not well tested.

This series is based on a merge of:
* The topic/r7s72100-v3.13-rc5-20131226 tag in my renesas tree
* net-next
  - Head revision: db34de939ae28954
    ("rose: cleanup checkpatch errors,spaces required")

Changes since v1 are noted in the changelog of each patch.

Simon Horman (3):
  sh_eth: Add support for r7s72100
  ARM: shmobile: r7s72100: Add clock for r7s72100-ether
  ARM: shmobile: genmai: Enable r7s72100-ether

 arch/arm/mach-shmobile/board-genmai.c   |  21 ++++++
 arch/arm/mach-shmobile/clock-r7s72100.c |   4 ++
 drivers/net/ethernet/renesas/sh_eth.c   | 119 ++++++++++++++++++++++++++++++--
 drivers/net/ethernet/renesas/sh_eth.h   |   4 +-
 4 files changed, 141 insertions(+), 7 deletions(-)

-- 
1.8.4
