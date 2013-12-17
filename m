From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: loading sctp when load sctp_probe
Date: Mon, 16 Dec 2013 20:11:52 -0500 (EST)
Message-ID: <20131216.201152.1820334028788828960.davem@davemloft.net>
References: <52AA783A.7090502@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab3LQBLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 20:11:54 -0500
In-Reply-To: <52AA783A.7090502@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 13 Dec 2013 11:00:10 +0800

> when I modprobe sctp_probe, it failed with "FATAL: ". I found that
> sctp should load before sctp_probe register jprobe. So I add a
> sctp_setup_jprobe for loading 'sctp' when first failed to register
> jprobe, just do this similar to dccp_probe.
> 
> v2: add MODULE_SOFTDEP and check of request_module, as suggested by Neil
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied.
