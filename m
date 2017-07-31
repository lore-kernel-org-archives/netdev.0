From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH v2 net-next 0/4] net: dsa: lan9303: Fix MDIO issues.
Date: Mon, 31 Jul 2017 09:51:06 +0200
Message-ID: <201707310951.07834.jbe@pengutronix.de>
References: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

On Sunday 30 July 2017 19:58:52 Egil Hjelmeland wrote:
> This series fix the MDIO interface for the lan9303 DSA driver.
> Bugs found after testing on actual HW.
>
> This series is extracted from the first patch of my first large
> series. Significant changes from that version are:
>  - use mdiobus_write_nested, mdiobus_read_nested.
>  - EXPORT lan9303_indirect_phy_ops
>
> Unfortunately I do not have access to i2c based system for
> testing.

A little bit late - the series is already applied...
I have just tested it on my LAN9303 connected via I2C and my setup still 
works.

Tested-by: Juergen Borleis <jbe@pengutronix.de>

Cheers
Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
