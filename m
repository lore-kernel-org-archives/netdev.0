From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] bonding: don't ensalve loopback device
Date: Mon, 24 Feb 2014 18:28:08 -0500 (EST)
Message-ID: <20140224.182808.25115590214594070.davem@davemloft.net>
References: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
	<1392970135-11904-5-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaBXX2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:28:10 -0500
In-Reply-To: <1392970135-11904-5-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 21 Feb 2014 16:08:55 +0800

> I could not see any effect that enslave a loopback device, so don't
> enslave such device for bonding.
> 
> Use pr_err to instead of pr_debug when return error.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

I do not agree at all with this patch, you can't just stop providing
functionality because you personally can't figure out a way in which
to use it.

I'll apply the other 3 patches, those are fine.
