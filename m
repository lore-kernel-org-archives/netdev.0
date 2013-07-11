From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dummy: fix oops when loading the dummy failed
Date: Thu, 11 Jul 2013 12:00:41 -0700 (PDT)
Message-ID: <20130711.120041.496311688309106017.davem@davemloft.net>
References: <51DE9122.9090908@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, fbl@redhat.com, netdev@vger.kernel.org,
	tanxiaojun@huawei.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463Ab3GKTAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 15:00:42 -0400
In-Reply-To: <51DE9122.9090908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 11 Jul 2013 19:04:02 +0800

> We rename the dummy in modprobe.conf like this:
> 
> install dummy0 /sbin/modprobe -o dummy0 --ignore-install dummy
> install dummy1 /sbin/modprobe -o dummy1 --ignore-install dummy
> 
> We got oops when we run the command:
> 
> modprobe dummy0
> modprobe dummy1
 ...
> The reason is that when loading dummy, if __rtnl_link_register() return failed,
> the init_module should return and avoid take the wrong path.
> 
> Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
