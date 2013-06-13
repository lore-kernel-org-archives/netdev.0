From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: make compare exist all the time
Date: Thu, 13 Jun 2013 00:46:07 -0700 (PDT)
Message-ID: <20130613.004607.546745883080814853.davem@davemloft.net>
References: <20130613012216.GA6788@localhost>
	<1371089138-4990-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371089138-4990-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 13 Jun 2013 10:05:38 +0800

> Commit da12c90e099789a63073fc82a19542ce54d4efb9
> "netlink: Add compare function for netlink_table"
> only set compare at the time we create kernel netlink,
> and reset compare to NULL at the time we finially
> release netlink socket, but netlink_lookup wants
> the compare exist always.
> 
> So we should set compare after we allocate nl_table,
> and never reset it. make comapre exist all the time.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, thanks.
