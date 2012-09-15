From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/24] net: seeq: use __iomem pointers for MMIO
Date: Sat, 15 Sep 2012 00:00:59 -0400 (EDT)
Message-ID: <20120915.000059.636218745264773259.davem@davemloft.net>
References: <1347658492-11608-1-git-send-email-arnd@arndb.de>
	<1347658492-11608-25-git-send-email-arnd@arndb.de>
	<20120914235607.GF12245@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, will.deacon@arm.com, nico@linaro.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120914235607.GF12245@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 15 Sep 2012 00:56:07 +0100

> On Fri, Sep 14, 2012 at 11:34:52PM +0200, Arnd Bergmann wrote:
>> ARM is moving to stricter checks on readl/write functions,
>> so we need to use the correct types everywhere.
> 
> Same comment as for eesox.  const void __iomem * is not a problem on
> x86, so it should not be a problem on ARM.

Agreed.
