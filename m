From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: boot test failure (net tree)
Date: Tue, 23 Aug 2011 11:41:29 +1000
Message-ID: <20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
References: <20110816.171525.639251389938336183.davem@davemloft.net>
	<20110817105002.efebf85d08460ad99b14be8e@canb.auug.org.au>
	<20110818152214.661858a61496993aaef2c704@canb.auug.org.au>
	<20110817.225356.1790362313048139752.davem@davemloft.net>
	<20110822113032.15087c2e190e2b0c3ee7dfb8@canb.auug.org.au>
	<20110823114011.a059aea0138b75bfa7eed1ce@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mikey@neuling.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110823114011.a059aea0138b75bfa7eed1ce@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Tue, 23 Aug 2011 11:40:11 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Mon, 22 Aug 2011 11:30:32 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Here's what I am applying as a merge fixup to the net tree today so that
> > my ppc64_defconfig builds actually build more or less the same set of
> > drivers as before this rearrangement.
> 
> And this today:

And this:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 23 Aug 2011 11:35:18 +1000
Subject: [PATCH] sparc: update sparc64_defconfig for net device movement

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 arch/sparc/configs/sparc64_defconfig |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/sparc/configs/sparc64_defconfig b/arch/sparc/configs/sparc64_defconfig
index 3c1e858..5732728 100644
--- a/arch/sparc/configs/sparc64_defconfig
+++ b/arch/sparc/configs/sparc64_defconfig
@@ -37,8 +37,6 @@ CONFIG_NET_KEY_MIGRATE=y
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
 CONFIG_NET_IPIP=m
-CONFIG_NET_IPGRE=m
-CONFIG_NET_IPGRE_BROADCAST=y
 CONFIG_IP_MROUTE=y
 CONFIG_IP_PIMSM_V1=y
 CONFIG_IP_PIMSM_V2=y
@@ -95,17 +93,19 @@ CONFIG_DM_SNAPSHOT=m
 CONFIG_DM_MIRROR=m
 CONFIG_DM_ZERO=m
 CONFIG_NETDEVICES=y
-CONFIG_NET_ETHERNET=y
 CONFIG_MII=m
+CONFIG_NET_VENDOR_AMD=y
 CONFIG_SUNLANCE=m
+CONFIG_NET_VENDOR_BROADCOM=y
+CONFIG_BNX2=m
+CONFIG_TIGON3=m
+CONFIG_NET_VENDOR_INTEL=y
+CONFIG_E1000=m
+CONFIG_E1000E=m
+CONFIG_NET_VENDOR_SUN=y
 CONFIG_HAPPYMEAL=m
 CONFIG_SUNGEM=m
 CONFIG_SUNVNET=m
-CONFIG_NET_PCI=y
-CONFIG_E1000=m
-CONFIG_E1000E=m
-CONFIG_TIGON3=m
-CONFIG_BNX2=m
 CONFIG_NIU=m
 # CONFIG_WLAN is not set
 CONFIG_PPP=m
@@ -126,13 +126,13 @@ CONFIG_INPUT_SPARCSPKR=y
 # CONFIG_SERIO_SERPORT is not set
 CONFIG_SERIO_PCIPS2=m
 CONFIG_SERIO_RAW=m
+# CONFIG_LEGACY_PTYS is not set
 # CONFIG_DEVKMEM is not set
 CONFIG_SERIAL_SUNSU=y
 CONFIG_SERIAL_SUNSU_CONSOLE=y
 CONFIG_SERIAL_SUNSAB=y
 CONFIG_SERIAL_SUNSAB_CONSOLE=y
 CONFIG_SERIAL_SUNHV=y
-# CONFIG_LEGACY_PTYS is not set
 CONFIG_FB=y
 CONFIG_FB_TILEBLITTING=y
 CONFIG_FB_SBUS=y
@@ -206,10 +206,8 @@ CONFIG_PRINTK_TIME=y
 CONFIG_MAGIC_SYSRQ=y
 CONFIG_DEBUG_KERNEL=y
 CONFIG_LOCKUP_DETECTOR=y
-CONFIG_DETECT_HUNG_TASK=y
 # CONFIG_SCHED_DEBUG is not set
 CONFIG_SCHEDSTATS=y
-# CONFIG_RCU_CPU_STALL_DETECTOR is not set
 CONFIG_SYSCTL_SYSCALL_CHECK=y
 CONFIG_BLK_DEV_IO_TRACE=y
 CONFIG_KEYS=y
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
