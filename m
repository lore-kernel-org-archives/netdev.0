From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] irda: use msecs_to_jiffies for conversion to jiffies
Date: Mon, 25 May 2015 17:46:41 -0400 (EDT)
Message-ID: <20150525.174641.1276114476375534221.davem@davemloft.net>
References: <1432534610-4643-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432534610-4643-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Mon, 25 May 2015 08:16:50 +0200

> API compliance scanning with coccinelle flagged:
> ./net/irda/timer.c:63:35-37: use of msecs_to_jiffies probably perferable
> 
> Converting milliseconds to jiffies by "val * HZ / 1000" technically
> is not a clean solution as it does not handle all corner cases correctly.
> By changing the conversion to use msecs_to_jiffies(val) conversion is
> correct in all cases. Further the () around the arithmetic expression
> was dropped.
> 
> Patch was compile tested for x86_64_defconfig + CONFIG_IRDA=m
> 
> Patch is against 4.1-rc4 (localversion-next is -next-20150522)
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied, thank you.
