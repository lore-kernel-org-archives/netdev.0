From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] tuntap: calculate rps hash only when needed
Date: Thu, 28 Apr 2016 16:39:08 -0400 (EDT)
Message-ID: <20160428.163908.1659396336398436917.davem@davemloft.net>
References: <1461640422-20779-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.ne, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcD1UjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:39:10 -0400
In-Reply-To: <1461640422-20779-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 25 Apr 2016 23:13:42 -0400

> There's no need to calculate rps hash if it was not enabled. So this
> patch export rps_needed and check it before trying to get rps
> hash. Tests (using pktgen to inject packets to guest) shows this can
> improve pps about 13% (when rps is disabled).
> 
> Before:
> ~1150000 pps
> After:
> ~1300000 pps
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
