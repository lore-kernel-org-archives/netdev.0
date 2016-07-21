From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: mv88e6xxx: rework EEPROM code
Date: Wed, 20 Jul 2016 21:11:08 -0700 (PDT)
Message-ID: <20160720.211108.701593532642432199.davem@davemloft.net>
References: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 20 Jul 2016 18:18:33 -0400

> Some switches can access an optional external EEPROM via its registers.
> 
> The 88E6352 family of switches have 8-bit address / 16-bit data access.
> The new 88E6390 family has 16-bit address / 8-bit data access.
> 
> This patchset cleans up the EEPROM code with 16-suffixed Global2 helpers
> and makes it easy to add future support for 8-bit data EEPROM access.
> 
> It also removes unnecessary mutexes and a few locked access functions.
> 
> Changes in v2:
>   - add missing Signed-off-by tag

Series applied, thanks.
