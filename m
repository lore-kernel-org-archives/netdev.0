From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2 v3] net: smsc911x: augment device tree bindings
Date: Wed, 07 Sep 2016 16:31:06 +0200
Message-ID: <5562302.TqOSBHraW1@wuerfel>
References: <1473256411-13965-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Jeremy Linton <jeremy.linton@arm.com>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>, devicetree@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:64841 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757197AbcIGObf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:31:35 -0400
In-Reply-To: <1473256411-13965-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, September 7, 2016 3:53:31 PM CEST Linus Walleij wrote:
> This adds device tree bindings for:
> 
> - An optional GPIO line for releasing the RESET signal to the
>   SMSC911x devices
> 
> - An optional PME (power management event) interrupt line that
>   can be utilized to wake up the system on network activity.
>   This signal exist on all the SMSC911x devices, it is just not
>   very often routed.
> 
> Both these lines are routed to the SoC on the Qualcomm APQ8060
> Dragonboard and thus needs to be bound in the device tree.
> 
> Cc: devicetree@vger.kernel.org
> Cc: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
