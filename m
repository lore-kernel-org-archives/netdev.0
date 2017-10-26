From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: Simplify dsa_slave_phy_setup()
Date: Wed, 25 Oct 2017 21:21:59 -0400
Message-ID: <87d15a3dqg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171026003205.13673-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, mnhu@prevas.dk,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37278 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbdJZBWB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:22:01 -0400
In-Reply-To: <20171026003205.13673-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Remove the code that tried to identify if a PHY designated by Device
> Tree required diversion through the DSA-created MDIO bus. This was
> created mainly for the bcm_sf2.c driver back when it did not have its
> own MDIO bus driver, which it now has since 461cd1b03e32 ("net: dsa:
> bcm_sf2: Register our slave MDIO bus").
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
