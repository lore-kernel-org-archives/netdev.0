From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 0/2] net: ethernet: mediatek: modify to use the
 PDMA for Ethernet RX
Date: Thu, 25 Aug 2016 10:26:29 +0800
Message-ID: <1472091991-1814-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 nelsonch.tw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

This patch set fixes the following issues

v1 -> v2: Fix the bugs of PDMA cpu index and interrupt settings in mtk_poll_rx()

v2 -> v3: Add GDM hardware settings to send packets to PDMA for RX

Nelson Chang (2):
  net: ethernet: mediatek: modify to use the PDMA instead of the QDMA
    for Ethernet RX
  net: ethernet: mediatek: modify GDM to send packets to the PDMA for RX

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 80 +++++++++++++++++------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 31 ++++++++++-
 2 files changed, 76 insertions(+), 35 deletions(-)

-- 
1.9.1
