From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: marvell: Only configure RGMII delays when
 using RGMII
Date: Tue, 31 Oct 2017 16:29:49 -0700
Message-ID: <82a345b3-3535-bfed-04f3-cb25e85b3612@gmail.com>
References: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Aaro Koskinen <aaro.koskinen@iki.fi>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:53566 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932817AbdJaX3y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 19:29:54 -0400
Received: by mail-qt0-f194.google.com with SMTP id n61so776930qte.10
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 16:29:53 -0700 (PDT)
In-Reply-To: <1509478288-27130-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2017 12:31 PM, Andrew Lunn wrote:
> The fix 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> uncovered another bug in the Marvell PHY driver, which broke the
> Marvell OpenRD platform. It relies on the bootloader configuring the
> RGMII delays and does not specify a phy-mode in its device tree.  The
> PHY driver should only configure RGMII delays if the phy mode
> indicates it is using RGMII. Without anything in device tree, the
> mv643xx Ethernet driver defaults to GMII.
> 
> Fixes: 5987feb38aa5 ("net: phy: marvell: logical vs bitwise OR typo")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
