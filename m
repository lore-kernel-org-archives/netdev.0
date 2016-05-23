From: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH 0/2 (linux-stable-4.5.y)] net: stmmac: MDIO fixes
Date: Mon, 23 May 2016 15:17:41 +0200
Message-ID: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
Reply-To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <robin.murphy-5wv7dgnIgG8@public.gmane.org>, <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, <afaerber-l3A5Bk7waGM@public.gmane.org>,
        <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, <bert-phGP8mJ4Mqk@public.gmane.org>,
        <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRBU4JRS5AKGQENTXNXJQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

These patches port some recent fixes for linux-4.5.y stable branch.
They fix the MDIO settings trying to cover the all possible scenario
when the stmmac is connected to a real transceiver or a switch.

These patches are needed for Kernel 4.5 where Lime2, BananaPi and Cubieboard2
show problems when use the stmmac:

https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=823493

Additional Note:

 o The 4.4.y branch has a previous version of the stmmac;
   that is not including the development that introduced
   the regressions for MDIO bus.

 o The 4.5.y kernel has "March_2013" stmmac version plus the
   patch that introduce some MDIO configuration problems
   so the regressions.

 o The 4.6.y has all the fixes on top of the "Oct_2015"
   stmmac version.

Giuseppe CAVALLARO (1):
  Revert "stmmac: Fix 'eth0: No PHY found' regression"

Giuseppe Cavallaro (1):
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 11 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 10 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 91 ++++++++++++++++------
 3 files changed, 70 insertions(+), 42 deletions(-)

-- 
2.7.4
