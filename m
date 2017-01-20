From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] cxgb4: hide unused warnings
Date: Fri, 20 Jan 2017 11:15:54 -0500 (EST)
Message-ID: <20170120.111554.775311724296711536.davem@davemloft.net>
References: <20170118145306.1004008-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, ganeshgr@chelsio.com,
        rahul.lakkireddy@chelsio.com, varun@chelsio.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbdATQSR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:18:17 -0500
In-Reply-To: <20170118145306.1004008-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Jan 2017 15:52:51 +0100

> The two new variables are only used inside of an #ifdef and cause
> harmless warnings when that is disabled:
> 
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function 'init_one':
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:9: error: unused variable 'port_vec' [-Werror=unused-variable]
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:6: error: unused variable 'v' [-Werror=unused-variable]
> 
> This adds another #ifdef around the declarations.
> 
> Fixes: 96fe11f27b70 ("cxgb4: Implement ndo_get_phys_port_id for mgmt dev")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
