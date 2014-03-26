From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] bonding: slight optimization and avoid
 spam for bond xmit path
Date: Wed, 26 Mar 2014 16:42:37 -0400 (EDT)
Message-ID: <20140326.164237.1565716552638473775.davem@davemloft.net>
References: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	joe@perches.com, kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbaCZUmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 16:42:40 -0400
In-Reply-To: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 25 Mar 2014 17:00:08 +0800

> v1->v2: Add ratelimit for debugging is not a good idea, it will miss some message
> 	if the user turns the debugging on, so remove the patch 3.
> 	use net_err_ratelimited instead of pr_err_ratelimited and use __func__ instead of
> 	bond_xmit_broadcast().

Series applied.
