From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: bcm_sf2: Unwind errors in correct order
Date: Fri, 29 Jul 2016 12:36:30 -0700
Message-ID: <e04c09b0-a2b6-3188-7b78-5621668bdb4d@gmail.com>
References: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32882 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcG2Tgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 15:36:33 -0400
Received: by mail-pa0-f47.google.com with SMTP id ks6so33842069pab.0
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 12:36:32 -0700 (PDT)
In-Reply-To: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/2016 12:35 PM, Florian Fainelli wrote:
> In case we cannot complete bcm_sf2_sw_setup() for any reason, and we
> go to the out_unmap label, but the MDIO bus has not been registered yet,
> we will hit the BUG condition in drivers/net/phy/mdio_bus.c about the
> bus not being registered. Fix this by dedicating a specific lable for
> when we fail after the MDIO bus has been successfully registered.
> 
> Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

David, this is for 'net', forgot to mention it in the subject.
-- 
Florian
