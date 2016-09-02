From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] mISDN: mark symbols static where possible
Date: Thu, 01 Sep 2016 23:37:15 -0700 (PDT)
Message-ID: <20160901.233715.178980675358878161.davem@davemloft.net>
References: <1472710584-497-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, dan.carpenter@oracle.com,
        mail@maciej.szmigiero.name, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbcIBGrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 02:47:20 -0400
In-Reply-To: <1472710584-497-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Thu,  1 Sep 2016 14:16:24 +0800

> We get a few warnings when building kernel with W=1:
> drivers/isdn/hardware/mISDN/hfcmulti.c:568:1: warning: no previous declaration for 'enablepcibridge' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:574:1: warning: no previous declaration for 'disablepcibridge' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:580:1: warning: no previous declaration for 'readpcibridge' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:608:1: warning: no previous declaration for 'writepcibridge' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:638:1: warning: no previous declaration for 'cpld_set_reg' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:645:1: warning: no previous declaration for 'cpld_write_reg' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:657:1: warning: no previous declaration for 'cpld_read_reg' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:674:1: warning: no previous declaration for 'vpm_write_address' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:681:1: warning: no previous declaration for 'vpm_read_address' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:695:1: warning: no previous declaration for 'vpm_in' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:716:1: warning: no previous declaration for 'vpm_out' [-Wmissing-declarations]
> drivers/isdn/hardware/mISDN/hfcmulti.c:1028:1: warning: no previous declaration for 'plxsd_checksync' [-Wmissing-declarations]
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
