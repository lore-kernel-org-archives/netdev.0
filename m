From: David Miller <davem@davemloft.net>
Subject: Re: Query regarding PTP_1588_CLOCK
Date: Mon, 15 Apr 2013 14:19:54 -0400 (EDT)
Message-ID: <20130415.141954.29857504310905187.davem@davemloft.net>
References: <38549.1366049778@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <38549.1366049778@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Mon, 15 Apr 2013 14:16:18 -0400

> In drivers/net/ethernet/intel/Kconfig, we see this:
> 
> config E1000E
>         tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
>         depends on PCI && (!SPARC32 || BROKEN)
>         select CRC32
>         select PTP_1588_CLOCK
>         ---help---
> 
> Is there a reason for the PTP_1588_CLOCK select?  That ends up
> forcing the PTP and PPS stuff into the kernel as well - and I don't
> use any of it.

You don't, but the driver does use it unconditionally.
