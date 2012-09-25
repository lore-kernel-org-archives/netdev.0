From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: fix trivial build error
Date: Tue, 25 Sep 2012 13:23:17 -0400 (EDT)
Message-ID: <20120925.132317.2132522444026609326.davem@davemloft.net>
References: <1348255713.12456.43.camel@mars>
	<1348560598-21233-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	chf.fritz@googlemail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1348560598-21233-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue, 25 Sep 2012 11:09:58 +0300

> The commit 5e953778a2aab04929a5e7b69f53dc26e39b079e ("ipconfig: add nameserver
> IPs to kernel-parameter ip=") introduces ic_nameservers_predef() that defined
> only for BOOTP. However it is used by ip_auto_config_setup() as well. This
> patch moves it outside of #ifdef BOOTP.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied, thanks.
