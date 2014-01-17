From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] bonding: try to enable SG features
 when adding a new, slave
Date: Thu, 16 Jan 2014 16:07:21 -0800 (PST)
Message-ID: <20140116.160721.427996343348396551.davem@davemloft.net>
References: <52D4FCB3.9000408@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, edumazet@google.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaAQAHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:07:22 -0500
In-Reply-To: <52D4FCB3.9000408@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 14 Jan 2014 17:00:35 +0800

> The commit b0ce3508(bonding: allow TSO being set on bonding master)
> has make the TSO being set for bond dev, but in some situation, if
> the slave did not set the NETIF_F_SG features yet, the bond master
> will miss the TSO features in netdev_fix_features because the TSO is
> depended on SG.
> 
> If the slave hw support SG features, but not set yet, I will try to
> open it when enslave the dev, better for performance.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

I really don't think we should force enable device features in slaves
that perhaps the user intentionally disabled, or perhaps the driver has
a reason to disable by default (lower performance, etc.)

I'm not applying this series, sorry.
