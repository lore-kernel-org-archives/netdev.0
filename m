From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.9-rc4-mm1] [m32r] Fix smc91x driver for m32r
Date: Tue, 12 Oct 2004 22:32:27 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041012223227.45a62301.akpm@osdl.org>
References: <416BFD79.1010306@pobox.com>
	<20041013.105243.511706221.takata.hirokazu@renesas.com>
	<416C8E0B.4030409@pobox.com>
	<20041013.121547.863739114.takata.hirokazu@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, takata@linux-m32r.org,
	linux-kernel@vger.kernel.org, paul.mundt@nokia.com, nico@cam.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268360AbUJMFef@vger.kernel.org>
To: Hirokazu Takata <takata.hirokazu@renesas.com>
In-Reply-To: <20041013.121547.863739114.takata.hirokazu@renesas.com>
List-Id: netdev.vger.kernel.org

Hirokazu Takata <takata.hirokazu@renesas.com> wrote:
>
>  This patch has been already applied to 2.6.9-rc4-mm1 kernel and 
>  you can also find it as
>  ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.9-rc4/2.6.9-rc4-mm1/broken-out/m32r-trivial-fix-of-smc91xh.patch

Well actually:

smc91x-revert-11923358-m32r-modify-drivers-net-smc91xc.patch
smc91x-assorted-minor-cleanups.patch
smc91x-set-the-mac-addr-from-the-smc_enable-function.patch
smc91x-fold-smc_setmulticast-into-smc_set_multicast_list.patch
smc91x-simplify-register-bank-usage.patch
smc91x-move-tx-processing-out-of-irq-context-entirely.patch
smc91x-use-a-work-queue-to-reconfigure-the-phy-from.patch
smc91x-fix-possible-leak-of-the-skb-waiting-for-mem.patch
smc91x-display-pertinent-register-values-from-the.patch
smc91x-straighten-smp-locking.patch
smc91x-cosmetics.patch
m32r-trivial-fix-of-smc91xh.patch
smc91x-fix-smp-lock-usage.patch
smc91x-more-smp-locking-fixes.patch
smc91x-fix-compilation-with-dma-on-pxa2xx.patch
smc91x-receives-two-bytes-too-many.patch
smc91x-release-on-chip-rx-packet-memory-asap.patch

I'll unload all those onto Jeff...
