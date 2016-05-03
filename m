From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Tue, 03 May 2016 12:06:52 -0400 (EDT)
Message-ID: <20160503.120652.1961585632822010448.davem@davemloft.net>
References: <57286F49.8050107@6wind.com>
	<1462268358-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160503100644.GE16459@soda.linbit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: lars.ellenberg@linbit.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160503100644.GE16459@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Ellenberg <lars.ellenberg@linbit.com>
Date: Tue, 3 May 2016 12:06:44 +0200

> Whereas using some arbitrary value will be wrong,
> and will needlessly break userland.

It cannot break userland.

A fundamental property of netlink is that all code must silently
ignore netlink attributes it does not understand.

This is why netlink is easily extensible.

If code isn't doing that, it is broken and must be fixed.
