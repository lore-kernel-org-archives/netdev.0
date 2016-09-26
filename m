From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: mark symbols static where possible
Date: Mon, 26 Sep 2016 02:24:56 -0400 (EDT)
Message-ID: <20160926.022456.1064618693608086094.davem@davemloft.net>
References: <1474783809-7615-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034473AbcIZGY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:24:59 -0400
In-Reply-To: <1474783809-7615-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 25 Sep 2016 14:10:09 +0800

> We get 10 warnings when building kernel with W=1:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:304:5: warning: no previous prototype for 'cxgb4_dcb_enabled' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:194:5: warning: no previous prototype for 'setup_sge_queues_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:241:6: warning: no previous prototype for 'free_sge_queues_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:268:5: warning: no previous prototype for 'cfg_queues_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:344:6: warning: no previous prototype for 'free_queues_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:353:5: warning: no previous prototype for 'request_msix_queue_irqs_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:379:6: warning: no previous prototype for 'free_msix_queue_irqs_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:393:6: warning: no previous prototype for 'name_msix_vecs_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:433:6: warning: no previous prototype for 'enable_rx_uld' [-Wmissing-prototypes]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c:442:6: warning: no previous prototype for 'quiesce_rx_uld' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
