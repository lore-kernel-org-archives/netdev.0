From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: bcm_sf2: Unwind errors in correct order
Date: Fri, 29 Jul 2016 15:40:00 -0400
Message-ID: <87vazojkrz.fsf@ketchup.mtl.sfl>
References: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57188 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcG2TkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 15:40:04 -0400
In-Reply-To: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In case we cannot complete bcm_sf2_sw_setup() for any reason, and we
> go to the out_unmap label, but the MDIO bus has not been registered yet,
> we will hit the BUG condition in drivers/net/phy/mdio_bus.c about the
> bus not being registered. Fix this by dedicating a specific lable for
> when we fail after the MDIO bus has been successfully registered.
>
> Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
