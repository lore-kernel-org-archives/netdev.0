From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] macvlan: fix the problem when mac address
 changes for passthru mode
Date: Mon, 02 Jun 2014 15:57:51 -0700 (PDT)
Message-ID: <20140602.155751.10391105293526523.davem@davemloft.net>
References: <53882611.1080302@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, vyasevic@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbaFBW5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 18:57:54 -0400
In-Reply-To: <53882611.1080302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 30 May 2014 14:32:49 +0800

> The macvlan dev should always have the same mac address like lowerdev
> when in the passthru mode, change the mac address alone will break the
> work mechanism, so when the lowerdev or macvlan mac address changes,
> we should propagate the changes to another dev.
> 
> v1->v2: Allow macvlan dev to change mac address for passthru mode and propagate to
> 	lowerdev.
> 
> v2->v3: Don't set the mac address to the lower dev's unicast address for
> 	passthru mode when mac address changes.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
