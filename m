From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: fix ipv6_cow_metrics for non
 DST_HOST case
Date: Sat, 14 Feb 2015 20:28:25 -0800 (PST)
Message-ID: <20150214.202825.1278379041799078856.davem@davemloft.net>
References: <1423771650-870555-1-git-send-email-kafai@fb.com>
	<1423786448-1158200-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbbBOEVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 23:21:17 -0500
In-Reply-To: <1423786448-1158200-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 12 Feb 2015 16:14:08 -0800

> ipv6_cow_metrics() currently assumes only DST_HOST routes require
> dynamic metrics allocation from inetpeer.  The assumption breaks
> when ndisc discovered router with RTAX_MTU and RTAX_HOPLIMIT metric.
> Refer to ndisc_router_discovery() in ndisc.c and note that dst_metric_set()
> is called after the route is created.
> 
> This patch creates the metrics array (by calling dst_cow_metrics_generic) in
> ipv6_cow_metrics().
 ...
> Fixes: 8e2ec639173f325 (ipv6: don't use inetpeer to store metrics for routes.)
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, thank you.
