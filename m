From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next v2] rocker: fix kcalloc parameter order
Date: Tue, 05 Sep 2017 14:57:40 -0700 (PDT)
Message-ID: <20170905.145740.1996370074892542800.davem@davemloft.net>
References: <20170905194958.3436-1-zahari.doychev@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: zahari.doychev@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752819AbdIEV5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:57:41 -0400
In-Reply-To: <20170905194958.3436-1-zahari.doychev@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zahari Doychev <zahari.doychev@linux.com>
Date: Tue,  5 Sep 2017 21:49:58 +0200

> The function calls to kcalloc use wrong parameter order and incorrect flags
> values. GFP_KERNEL is used instead of flags now and the order is corrected.
> 
> The change was done using the following coccinelle script:
> 
> @@
> expression E1,E2;
> type T;
> @@
> 
> -kcalloc(E1, E2, sizeof(T))
> +kcalloc(E2, sizeof(T), GFP_KERNEL)
> 
> Signed-off-by: Zahari Doychev <zahari.doychev@linux.com>

Applied, thank you.
