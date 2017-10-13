From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net] net: dsa: mv88e6060: fix switch MAC address
Date: Fri, 13 Oct 2017 19:09:22 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B519C6@CHN-SV-EXMX02.mchp-main.com>
References: <20171013173922.26536-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <kernel@savoirfairelinux.com>,
        <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <David.Laight@ACULAB.COM>
To: <vivien.didelot@savoirfairelinux.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013173922.26536-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Vivien Didelot
> Sent: Friday, October 13, 2017 1:39 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; kernel@savoirfairelinux.com; David S.
> Miller; Florian Fainelli; Andrew Lunn; David Laight; Vivien Didelot
> Subject: [PATCH net] net: dsa: mv88e6060: fix switch MAC address
> 
> The 88E6060 Ethernet switch always transmits the multicast bit of the
> switch MAC address as a zero. It re-uses the corresponding bit 8 of the
> register "Switch MAC Address Register Bytes 0 & 1" for "DiffAddr".
> 
> If the "DiffAddr" bit is 0, then all ports transmit the same source
> address. If it is set to 1, then bit 2:0 are used for the port number.
> 
> The mv88e6060 driver is currently wrongly shifting the MAC address byte
> 0 by 9. To fix this, shift it by 8 as usual and clear its bit 0.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

Reviewed-by: Woojung Huh <woojung.huh@microchip.com>

- Woojung
