From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: mv88e6xxx: isolate Global2
 support
Date: Tue, 06 Sep 2016 12:58:28 -0700 (PDT)
Message-ID: <20160906.125828.797045076262810512.davem@davemloft.net>
References: <20160902184534.28594-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902184534.28594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  2 Sep 2016 14:45:31 -0400

> Registers of Marvell chips are organized in internal SMI devices.
> 
> One of them at address 0x1C is called Global2. It provides an extended
> set of registers, used for interrupt control, EEPROM access, indirect
> PHY access (to bypass the PHY Polling Unit) and cross-chip setup.
> 
> Most chips have it, but some others don't (older ones such as 6060).
> 
> Now that its related code is isolated in mv88e6xxx_g2_* functions, move
> it to its own global2.c file, making most of its setup code static.
> 
> Then make its compilation optional, which allows to reduce the size of
> the mv88e6xxx driver for devices such as home routers embedding Ethernet
> chips without Global2 support.
> 
> It is present on most recent chips, thus enable its support by default.
> 
> Changes in v2: fail probe if GLOBAL2 is required but not enabled.

Series applied, thanks.
