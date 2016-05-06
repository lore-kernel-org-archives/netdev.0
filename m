From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 06/21] net: dsa: mv88e6xxx: factorize MAC
 address setting
Date: Sat, 7 May 2016 00:23:20 +0200
Message-ID: <20160506222320.GB2073@lunn.ch>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462571843-14397-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462571843-14397-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -378,6 +385,7 @@ enum mv88e6xxx_cap {
>  #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
>  #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
>  #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
> +#define MV88E6XXX_FLAG_SWITCH_MAC	BIT(MV88E6XXX_CAP_SWITCH_MAC_WOL_WOF)
>  #define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
>  #define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)

There is a general pattern here that the flag has a name derived from
the capability. Except you dropped the WOL_WOF here. It would probably
be better to not have WOL_WOF at all.

   Andrew
