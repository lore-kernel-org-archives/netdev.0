From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Move jiffies_to_usecs immediately before loop
Date: Thu, 21 May 2015 17:23:35 -0400 (EDT)
Message-ID: <20150521.172335.2013762602695904530.davem@davemloft.net>
References: <1432097092.2870.266.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432097092.2870.266.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 19 May 2015 21:44:52 -0700

> 30 usecs (or really, 1 jiffy) can go by pretty fast.
> 
> Move the set of the timeout immediately before the loop.
> 
> Remove the unnecessary max(1ul, usecs_to_jiffies(30)) as
> usecs_to_jiffies with a non-zero constant is guaranteed
> to be non-zero.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This looks fine, applied to net-next, thanks Joe.
