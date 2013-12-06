From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: disable max_burst when the max_burst is 0
Date: Thu, 05 Dec 2013 20:56:24 -0500 (EST)
Message-ID: <20131205.205624.1643659823573912858.davem@davemloft.net>
References: <529C2E01.3090005@huawei.com>
	<529EF6B7.7000501@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dborkman@redhat.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3LFB40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:56:26 -0500
In-Reply-To: <529EF6B7.7000501@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 4 Dec 2013 17:32:39 +0800

> As Michael pointed out that when max_burst is 0, it just disable
> max_burst. It declared in rfc6458#section-8.1.24. so add the check
> in sctp_transport_burst_limited, when it 0, just do nothing.
> 
> Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Suggested-by: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
