From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] geneve: ensure ECN info is handled properly in all
 tx/rx paths
Date: Tue, 22 Sep 2015 16:50:25 -0700 (PDT)
Message-ID: <20150922.165025.2165471262567454938.davem@davemloft.net>
References: <20150920.222459.2251924175671848436.davem@davemloft.net>
	<1442845749-23978-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759951AbbIVXu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:50:26 -0400
In-Reply-To: <1442845749-23978-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 21 Sep 2015 10:29:09 -0400

> Partially due to a pre-exising "thinko", the new metadata-based tx/rx
> paths were handling ECN propagation differently than the traditional
> tx/rx paths.  This patch removes the "thinko" (involving multiple
> ip_hdr assignments) on the rx path and corrects the ECN handling on
> both the rx and tx paths.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> v3 -- replace "geneve: remove use of internal IP header when calling
> 	IP_ECN_decapsulate", include geneve_xmit bits
> v2 -- ensure the collect_md path still calls IP_ECN_decapsulate

Applied, thanks John.
