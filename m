From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -v2] netconsole: switch init_netconsole() to
 late_initcall if build-in
Date: Tue, 20 Sep 2011 15:45:28 -0400 (EDT)
Message-ID: <20110920.154528.2085500980809143629.davem@davemloft.net>
References: <1315899939.3402.2.camel@snb>
	<20110913010158.1652cdee.akpm@linux-foundation.org>
	<1315903130.3375.7.camel@snb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm00@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: ming.m.lin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315903130.3375.7.camel@snb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lin Ming <ming.m.lin@intel.com>
Date: Tue, 13 Sep 2011 16:38:50 +0800

> Subject: [PATCH -v3] netconsole: switch init_netconsole() to late_initcall
> 
> Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> regression that netconsole does not work if netconsole and network
> device driver are build into kernel, because netconsole is linked
> before network device driver.
> 
> Andrew Morton suggested to fix this with initcall ordering.
> Fixes it by switching init_netconsole() to late_initcall.
> 
> Signed-off-by: Lin Ming <ming.m.lin@intel.com>

Applied, thanks.
