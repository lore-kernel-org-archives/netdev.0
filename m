From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_re: add MAY_USE_DEVLINK dependency
Date: Sat, 29 Jul 2017 14:18:25 -0700 (PDT)
Message-ID: <20170729.141825.1080468412995768419.davem@davemloft.net>
References: <20170727102951.26964-1-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        devesh.sharma@broadcom.com, arnd@arndb.de,
        michael.chan@broadcom.com
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdG2VS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 17:18:26 -0400
In-Reply-To: <20170727102951.26964-1-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Thu, 27 Jul 2017 06:29:51 -0400

> bnxt_en depends on MAY_USE_DEVLINK; this is used to force bnxt_en
> to be =m when DEVLINK is =m.
> 
> Now, bnxt_re selects bnxt_en. Unless bnxt_re also explicitly calls
> out dependency on MAY_USE_DEVLINK, Kconfig does not force bnxt_re
> to be =m when DEVLINK is =m, causing the following error:
> 
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function
> `bnxt_dl_register':
> bnxt_vfr.c:(.text+0x1440): undefined reference to `devlink_alloc'
> bnxt_vfr.c:(.text+0x14c0): undefined reference to `devlink_register'
> bnxt_vfr.c:(.text+0x14e0): undefined reference to `devlink_free'
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function
> `bnxt_dl_unregister':
> bnxt_vfr.c:(.text+0x1534): undefined reference to `devlink_unregister'
> bnxt_vfr.c:(.text+0x153c): undefined reference to `devlink_free'
> 
> Fix this by adding MAY_USE_DEVLINK dependency in bnxt_re.
> 
> Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Applied.
