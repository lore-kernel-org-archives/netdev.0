From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netcp: use pointer to fix build fail
Date: Mon, 22 Feb 2016 12:46:51 -0500 (EST)
Message-ID: <20160222.124651.135368011882918651.davem@davemloft.net>
References: <1456161943-9206-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.r.fastabend@intel.com
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456161943-9206-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Mon, 22 Feb 2016 22:55:43 +0530

> While building keystone_defconfig of arm we are getting build failure
> with the error:
 ...
> The callback of ndo_setup_tc should be:
> int (*ndo_setup_tc)(struct net_device *dev, u32 handle, __be16 protocol,
>                     struct tc_to_netdev *tc);
> 
> But we missed marking the last argument as a pointer.
> 
> Fixes: 16e5cc647173 ("net: rework setup_tc ndo op to consume general tc operand")
> CC: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Applied, thanks.
