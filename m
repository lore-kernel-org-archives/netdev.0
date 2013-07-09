From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: enic: release rtnl_lock on error-path
Date: Tue, 09 Jul 2013 12:56:38 -0700 (PDT)
Message-ID: <20130709.125638.86796731717687170.davem@davemloft.net>
References: <20130708072251.20540.50413.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	neepatel@cisco.com, nistrive@cisco.com, roprabhu@cisco.com,
	benve@cisco.com
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130708072251.20540.50413.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 11:22:51 +0400

> enic_change_mtu_work() must call rtnl_unlock() on all exiting paths.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied.
