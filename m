From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 00/11] net: mediatek: various small fixes
Date: Fri, 10 Jun 2016 13:27:57 +0200
Message-ID: <1465558088-15265-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

This series contains various small fixes that we stumbled across while
doing thorough testing and code level reviewing of the driver. The only
patch that sticks out is the first one, which addresses a DQL related
issue. The rest are just minor fixes.

Changes in V2:
* drop the DQL patch from the list until a better solution is found

John Crispin (11):
  net: mediatek: add missing return code check
  net: mediatek: fix missing free of scratch memory
  net: mediatek: invalid buffer lookup in mtk_tx_map()
  net: mediatek: dropped rx packets are not being counted properly
  net: mediatek: add next data pointer coherency protection
  net: mediatek: disable all interrupts during probe
  net: mediatek: fix threshold value
  net: mediatek: increase watchdog_timeo
  net: mediatek: fix off by one in the TX ring allocation
  net: mediatek: only wake the queue if it is stopped
  net: mediatek: remove superfluous queue wake up call

 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   61 ++++++++++++++++++---------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    3 ++
 2 files changed, 45 insertions(+), 19 deletions(-)

-- 
1.7.10.4
