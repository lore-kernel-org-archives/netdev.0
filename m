From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCHv4] net: dsa: add SMSC/Microchip LAN9303 three port ethernet switch driver
Date: Thu, 13 Apr 2017 09:30:10 +0200
Message-ID: <201704130930.11857.jbe@pengutronix.de>
References: <20170412140218.1076-1-jbe@pengutronix.de> <20170412.120446.1436199142955903765.davem@davemloft.net> <20170412.131520.2000433123223699514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:55547 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752803AbdDMHar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:30:47 -0400
In-Reply-To: <20170412.131520.2000433123223699514.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wednesday 12 April 2017 19:15:20 David Miller wrote:
> [...]
> >> Please note: the "MDIO managed mode" driver part isn't tested yet. I
> >> have used and tested the "I2C managed mode" only.
> >
> > Series applied, thank you.
>
> Actually, this doesn't even build.  Please fix this and resubmit.

Sorry, did a temporary fix in 'dsa_priv.h'a and so this missing #include 
slipped through. Fix in v5 is coming soon.

Regards,
Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
