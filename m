From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: dsa: abstract PHY accesses
Date: Mon, 15 Aug 2016 16:44:16 -0700 (PDT)
Message-ID: <20160815.164416.889081072849280440.davem@davemloft.net>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 15 Aug 2016 17:18:56 -0400

> The Marvell 88E6xxx switch chips have different way to access the PHY
> devices registers. 
> 
> Old chips use a direct access to the PHY registers. Next chips have a
> PHY Polling Unit (PPU) which needs to be disabled before accessing PHY
> registers. Newer chips have an indirect access to the PHY devices so
> that disabling the PPU is not necessary.
> 
> This patchset abstracts these accesses behind a new mv88e6xxx_phy_* API.
> 
> It also has the side effect to fix the temperature access code for
> 88E61xx chips which were using the wrong PHY access functions.

Looks good, series applied, thanks.
