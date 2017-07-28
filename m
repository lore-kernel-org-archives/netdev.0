From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: lan9303: Renamed indirect phy access functions
Date: Fri, 28 Jul 2017 11:37:32 -0400
Message-ID: <87iniclghv.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no> <20170728151157.28983-4-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-4-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> Preparing for the following fix of MDIO phy access:
>
> Renamed functions that access PHY 1 and 2 indirectly through PMI
> registers.
>
>  lan9303_port_phy_reg_wait_for_completion() to
>  lan9303_indirect_phy_wait_for_completion()
>
>  lan9303_port_phy_reg_read() to
>  lan9303_indirect_phy_read()
>
>  lan9303_port_phy_reg_write() to
>  lan9303_indirect_phy_write()
>
> Also changed "val" parameter of lan9303_indirect_phy_write() to u16,
> for clarity.
>
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
