From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v3] net: smsc911x: request and deassert optional
 RESET GPIO
Date: Wed, 07 Sep 2016 21:06:17 -0700 (PDT)
Message-ID: <20160907.210617.685340162025675932.davem@davemloft.net>
References: <1473256422-14012-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        linux@roeck-us.net, jeremy.linton@arm.com,
        kamlakant.patel@broadcom.com, p.fedin@samsung.com
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbcIHEGS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 00:06:18 -0400
In-Reply-To: <1473256422-14012-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Wed,  7 Sep 2016 15:53:42 +0200

> On some systems (such as the Qualcomm APQ8060 Dragonboard) the
> RESET signal of the SMSC911x is not pulled up by a resistor (or
> the internal pull-up that will pull it up if the pin is not
> even connected) but instead connected to a GPIO line, so that
> the operating system must explicitly deassert RESET before use.
> 
> Support this in the SMSC911x driver so this ethernet connector
> can be used on such targets.
> 
> Notice that we request the line to go logical low (deassert)
> whilst the line on the actual component is active low. This
> is managed in the respective hardware description when
> specifying the GPIO line with e.g. device tree or ACPI. With
> device tree it looks like this in one case:
> 
>   reset-gpios = <&tlmm 30 GPIO_ACTIVE_LOW>;
> 
> Which means that logically requesting the RESET line to be
> deasserted will result in the line being driven high, taking
> the device out of reset.
> 
> Cc: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Applied.
