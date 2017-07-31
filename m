From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] net: dsa: lan9303: Fix MDIO issues.
Date: Sun, 30 Jul 2017 19:23:45 -0700 (PDT)
Message-ID: <20170730.192345.2215743860694319208.davem@davemloft.net>
References: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Sun, 30 Jul 2017 19:58:52 +0200

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
> 
> Changes from first version:
>  - Change EXPORT_SYMBOL to EXPORT_SYMBOL_GPL

Series applied, thanks.
