From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] networking: fm10k: Fix build failure
Date: Fri, 10 Oct 2014 01:01:21 -0400 (EDT)
Message-ID: <20141010.010121.1739918681035567554.davem@davemloft.net>
References: <1412916929-21592-1-git-send-email-bobby.prani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: bobby.prani@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1412916929-21592-1-git-send-email-bobby.prani@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Pranith Kumar <bobby.prani@gmail.com>
Date: Fri, 10 Oct 2014 00:55:29 -0400

> The latest linus git tip (3.18-rc1) fails with the following build failure. Fix
> this by making PTP support explicit for fm10k driver.
> 
> rivers/built-in.o: In function `fm10k_ptp_register':
> (.text+0x12e760): undefined reference to `ptp_clock_registER'
> drivers/built-in.o: In function `fm10k_ptp_unregister':
> (.text+0x12e7dc): undefined reference to `ptp_clock_unregister'
> Makefile:930: recipe for target 'vmlinux' failed
> 
> Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>

Please follow what other drivers do, which is to use "select" on this
Kconfig symbol.

Thanks.

------------------------------------------------------------------------------
Meet PCI DSS 3.0 Compliance Requirements with EventLog Analyzer
Achieve PCI DSS 3.0 Compliant Status with Out-of-the-box PCI DSS Reports
Are you Audit-Ready for PCI DSS 3.0 Compliance? Download White paper
Comply to PCI DSS 3.0 Requirement 10 and 11.5 with EventLog Analyzer
http://pubads.g.doubleclick.net/gampad/clk?id=154622311&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
