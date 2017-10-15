From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Sat, 14 Oct 2017 18:30:49 -0700 (PDT)
Message-ID: <20171014.183049.1984702535102046922.davem@davemloft.net>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        David.Laight@ACULAB.COM
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 13 Oct 2017 14:18:04 -0400

> An Ethernet switch may support having a MAC address, which can be used
> as the switch's source address in transmitted full-duplex Pause frames.
> 
> If a DSA switch supports the related .set_addr operation, the DSA core
> sets the master's MAC address on the switch.
> 
> This won't make sense anymore in a multi-CPU ports system, because there
> won't be a unique master device assigned to a switch tree.
> 
> Moreover this operation is confusing because it makes the user think
> that it could be used to program the switch with the MAC address of the
> CPU/management port such that MAC address learning can be disabled on
> said port, but in fact, that's not how it is currently used.
> 
> To fix this, assign a random MAC address at setup time in the mv88e6060
> and mv88e6xxx drivers before removing .set_addr completely from DSA.
> 
> Changes in v3:
>   - include fix for mv88e6060 switch MAC address setter.
> 
> Changes in v2:
>   - remove .set_addr implementation from drivers and use a random MAC.

Series applied,thanks Vivien.
