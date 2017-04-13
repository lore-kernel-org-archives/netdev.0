From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/1] net: ipv4: Refine the
 ipv4_default_advmss
Date: Thu, 13 Apr 2017 13:20:20 -0400 (EDT)
Message-ID: <20170413.132020.858368201657633084.davem@davemloft.net>
References: <1491971643-117736-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org,
        fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbdDMRUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 13:20:22 -0400
In-Reply-To: <1491971643-117736-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Wed, 12 Apr 2017 12:34:03 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> 1. Don't get the metric RTAX_ADVMSS of dst.
> There are two reasons.
> 1) Its caller dst_metric_advmss has already invoke dst_metric_advmss
> before invoke default_advmss.
> 2) The ipv4_default_advmss is used to get the default mss, it should
> not try to get the metric like ip6_default_advmss.
> 
> 2. Use sizeof(tcphdr)+sizeof(iphdr) instead of literal 40.
> 
> 3. Define one new macro IPV4_MAX_PMTU instead of 65535 according to
> RFC 2675, section 5.1.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Simplify the codes again, per Joe
>  v2: Use min instead of unnecessary min_t, per Joe
>  v1: initial version

Applied, thanks.
