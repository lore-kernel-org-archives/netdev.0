From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] bonding: support QinQ for bond arp
 interval
Date: Wed, 26 Mar 2014 16:42:47 -0400 (EDT)
Message-ID: <20140326.164247.1476959528621346758.davem@davemloft.net>
References: <1395740684-12224-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	joe@perches.com, kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbaCZUmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 16:42:50 -0400
In-Reply-To: <1395740684-12224-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 25 Mar 2014 17:44:41 +0800

> v1->v2: remvoe the comment "TODO: QinQ?".
> 	convert pr_xxx() to pr_xxx_ratelimited() for arp interval.
> 
> v2->v3: remove the unnecessary log for arp interval and add net ratelimit to
> 	avoid spam log.
> 
> v3->v4: Add ratelimit for debugging is not a good idea, it will miss some message
> 	if the user turns the debugging on, so don't add ratelimited on debugging.

Series applied.
