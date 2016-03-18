From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: consolidate lock/unlock into unlock_wait
Date: Fri, 18 Mar 2016 17:37:02 -0400 (EDT)
Message-ID: <20160318.173702.788700055531273267.davem@davemloft.net>
References: <1458293525-16842-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458293525-16842-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Fri, 18 Mar 2016 10:32:05 +0100

> The spin_lock()/spin_unlock() is synchronizing on the adapter->work_lock
> as the comment also suggests, which is equivalent to spin_unlock_wait()
> but the later should be more efficient.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

There really is no justification for this change.

This is an optimization in a slow-path of the driver.

The device is a rarely used older piece of hardware.

The amount of testers of this driver is probably approximating zero.

So there is only risk of breakage from this change, and absolutely
zero upside.

Therefore, I'm not applying this patch, and I'd kindly like to ask
you to please consider such issues in the future for these kinds of
transformations.

Thanks.
