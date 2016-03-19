From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 0/2] Create ancient subdirectories for old
 hardware
Date: Fri, 18 Mar 2016 22:11:53 -0400 (EDT)
Message-ID: <20160318.221153.997255526626920777.davem@davemloft.net>
References: <1458340518.26915.30.camel@perches.com>
	<cover.1458347329.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1458347329.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 18 Mar 2016 17:33:29 -0700

> Maybe something like this:
> 
> Old, rare, and unsupported hardware should be exposed as ancient.
> 
> The drivers for these ancient hardwares are generally untested with
> current kernels.

Moving drivers has a long term maintainence cost.

If they've moved into drivers/net proper, we have to maintain
them there forever.
