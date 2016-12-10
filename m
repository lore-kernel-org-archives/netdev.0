From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc911x: back out silently on probe deferrals
Date: Fri, 09 Dec 2016 23:05:47 -0500 (EST)
Message-ID: <20161209.230547.1113699691008813275.davem@davemloft.net>
References: <1481289480-22096-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        linux@roeck-us.net, jeremy.linton@arm.com,
        kamlakant.patel@broadcom.com, p.fedin@samsung.com
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbcLJEFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 23:05:49 -0500
In-Reply-To: <1481289480-22096-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Fri,  9 Dec 2016 14:18:00 +0100

> When trying to get a regulator we may get deferred and we see
> this noise:
> 
> smsc911x 1b800000.ethernet-ebi2 (unnamed net_device) (uninitialized):
>    couldn't get regulators -517
> 
> Then the driver continues anyway. Which means that the regulator
> may not be properly retrieved and reference counted, and may be
> switched off in case noone else is using it.
> 
> Fix this by returning silently on deferred probe and let the
> system work it out.
> 
> Cc: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Looks good, applied, thanks.
