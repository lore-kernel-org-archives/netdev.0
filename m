From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 v2] bonding: add rtnl protection for
 bonding_store_fail_over_mac
Date: Wed, 24 Jul 2013 17:46:00 -0700 (PDT)
Message-ID: <20130724.174600.2157744762141467750.davem@davemloft.net>
References: <51EE2FF3.3000601@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab3GYAqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:46:01 -0400
In-Reply-To: <51EE2FF3.3000601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 23 Jul 2013 15:25:39 +0800

> We need rtnl protection while reading slave_cnt and updating
> the .fail_over_mac, and it also follows the logic "don't change
> anything slave-related without rtnl". :)
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
