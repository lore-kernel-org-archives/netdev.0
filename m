From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Fri, 13 Jan 2017 12:14:07 -0500 (EST)
Message-ID: <20170113.121407.448230751444957957.davem@davemloft.net>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1484241755-17603-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Thu, 12 Jan 2017 19:22:34 +0200

> This pull request includes one patch from Leon, this patch as described 
> below will change the driver directory structure and layout for better,
> logical and modular driver files separation.
> 
> This change is important to both rdma and net maintainers in order to 
> have smoother management of driver patches for different mlx5 sub modules
> and smoother rdma-next vs. net-next features submissions.
> 
> Please find more info below -in the tag commit message-,
> review and let us know if there's any problem.
> 
> This change doesn't introduce any conflicts with the current mlx5
> fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
> worked flawlessly with no issues.
> 
> This is the last pull request meant for both rdma-next and net-next.
> Once pulled, this will be the base shared code for both trees.

This is pretty crazy, it will make all bug fix backporting to -stable
a complete nightmare for myself, Doug, various distribution maintainers
and many other people who quietly have to maintain their own trees and
do backporting.

I really don't think you can justify this rearrangement based upon the
consequences and how much activity happens in this driver.

You should have thought long and hard about the layout a long time ago
rather than after the driver has been in the tree for many years.

Sorry.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
