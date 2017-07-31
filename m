From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 0/4] net-next: mediatek: add support for ethernet
 on MT7622 SoC
Date: Mon, 31 Jul 2017 18:05:07 +0800
Message-ID: <cover.1501494522.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

Changes since v2:
- update John's mail

Changes since v1:
- add refinement for ethernet clock management
- take out the code block for ESW, add it until ESW driver is actually introduced

The series adds the driver for ethernet controller found on MT7622 SoC.
There are additions against with previous MT7623 SoC such as shared SGMII
given for the dual GMACs and built-in 5-ports 10/100 embedded switch support
(ESW). Thus more clocks consumers and SGMII hardware setup for the extra
features are all introduced here and as for the support for ESW that would be
planned to add in the separate patch integrating with DSA infrastructure
in the future.

Currently testing successfully is done with those patches for the conditions
such as GMAC2 with IP1001 PHY via RGMII and GMAC1/2 with RTL8211F PHY via SGMII.


Sean Wang (4):
  dt-bindings: net: mediatek: add support for MediaTek MT7623 and MT7622
    SoC
  net-next: mediatek: add platform data to adapt into various hardware
  net-next: mediatek: add support for MediaTek MT7622 SoC
  MAINTAINERS: add Sean/Nelson as MediaTek ethernet maintainers

 .../devicetree/bindings/net/mediatek-net.txt       |  12 +-
 MAINTAINERS                                        |   4 +-
 drivers/net/ethernet/mediatek/Kconfig              |   6 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 142 +++++++++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  73 ++++++++++-
 5 files changed, 215 insertions(+), 22 deletions(-)

-- 
2.7.4
