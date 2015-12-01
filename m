From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add support for netdev notifier error injection
Date: Tue, 01 Dec 2015 15:32:39 -0500 (EST)
Message-ID: <20151201.153239.181267823939116963.davem@davemloft.net>
References: <1448714728-12729-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com, roopa@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	akinobu.mita@gmail.com, netdev@vger.kernel.org
To: razor@blackwall.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448714728-12729-1-git-send-email-razor@blackwall.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sat, 28 Nov 2015 13:45:28 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This module allows to insert errors in some of netdevice's notifier
> events. All network drivers use these notifiers to signal various events
> and to check if they are allowed, e.g. PRECHANGEMTU and CHANGEMTU
> afterwards. Until recently I had to run failure tests by injecting
> a custom module, but now this infrastructure makes it trivial to test
> these failure paths. Some of the recent bugs I fixed were found using
> this module.
> Here's an example:
>  $ cd /sys/kernel/debug/notifier-error-inject/netdev
>  $ echo -22 > actions/NETDEV_CHANGEMTU/error
>  $ ip link set eth0 mtu 1024
>  RTNETLINK answers: Invalid argument
> 
> CC: Akinobu Mita <akinobu.mita@gmail.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netdev <netdev@vger.kernel.org>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This looks fine, applied to net-next, thanks!
