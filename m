From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: unexport cxgb4_dcb_enabled
Date: Mon, 03 Oct 2016 01:33:41 -0400 (EDT)
Message-ID: <20161003.013341.169534682220012853.davem@davemloft.net>
References: <20160930161544.41614-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, rahul.lakkireddy@chelsio.com,
        nab@linux-iscsi.org, varun@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbcJCFdo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 01:33:44 -0400
In-Reply-To: <20160930161544.41614-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 30 Sep 2016 18:15:33 +0200

> A recent cleanup marked cxgb4_dcb_enabled as 'static', which is correct, but this ignored
> how the symbol is also exported. In addition, the export can be compiled out when modules
> are disabled, causing a harmless compiler warning in configurations for which it is not
> used at all:
> 
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:282:12: error: 'cxgb4_dcb_enabled' defined but not used [-Werror=unused-function]
> 
> This removes the export and moves the function into the correct #ifdef so we only build
> it when there are users.
> 
> Fixes: 50935857f878 ("cxgb4: mark symbols static where possible")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
