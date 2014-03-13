From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: set correct vlan id for alb xmit path
Date: Thu, 13 Mar 2014 15:45:32 -0400 (EDT)
Message-ID: <20140313.154532.1174268119094634467.davem@davemloft.net>
References: <531E6D77.60808@huawei.com>
	<5320298F.2010101@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593AbaCMTpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:45:34 -0400
In-Reply-To: <5320298F.2010101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 12 Mar 2014 17:31:59 +0800

> The commit d3ab3ffd1d728d7ee77340e7e7e2c7cfe6a4013e
> (bonding: use rlb_client_info->vlan_id instead of ->tag)
> remove the rlb_client_info->tag, but occur some issues,
> The vlan_get_tag() will return 0 for success and -EINVAL for
> error, so the client_info->vlan_id always be set to 0 if the
> vlan_get_tag return 0 for success, so the client_info would
> never get a correct vlan id.
> 
> We should only set the vlan id to 0 when the vlan_get_tag return error.
> 
> Fixes: d3ab3ffd1d7 (bonding: use rlb_client_info->vlan_id instead of ->tag)
> 
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
