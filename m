From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] spider_net: fix compile issue introduced by driver
 move
Date: Thu, 11 Aug 2011 22:54:17 -0700 (PDT)
Message-ID: <20110811.225417.852034314133874910.davem@davemloft.net>
References: <20110812144131.59de312ee6e1a9e8865c1a85@canb.auug.org.au>
	<20110812150003.1e2ba71018bea040fc7649d7@canb.auug.org.au>
	<1313128038.4588.5.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1313128038.4588.5.camel@jtkirshe-mobl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Aug 2011 22:47:17 -0700

> This is just an example of the change that would be needed to resolve
> defconfig issues.  The below patch should resolve the cxgb3/4 errors.  I
> have not made the necessary changes to resolve the mlx4 issues in this
> patch.  I can generate those as well, if need be.

The dependencies should be such that the Kconfig system will work
out whatever is needed.

If the build breaks, the dependencies are wrong and we need to fix
them.  Updating defconfigs should not be necessary to get a clean
build, it should "just work"
