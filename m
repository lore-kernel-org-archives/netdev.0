From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy registers directly
Date: Fri, 28 Jul 2017 11:39:22 -0400
Message-ID: <87fudglget.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no> <20170728151157.28983-5-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-5-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

> +const struct lan9303_phy_ops lan9303_indirect_phy_ops = {
> +	.phy_read = lan9303_indirect_phy_read,
> +	.phy_write = lan9303_indirect_phy_write,
> +};
> +EXPORT_SYMBOL(lan9303_indirect_phy_ops);

Isn't EXPORT_SYMBOL_GPL prefered over EXPORT_SYMBOL?


Thanks,

        Vivien
