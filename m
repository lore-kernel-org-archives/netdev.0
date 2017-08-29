From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Tue, 29 Aug 2017 14:23:17 -0700
Message-ID: <237eee82-2edb-56c0-d644-2e6253a178dc@gmail.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd> <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd> <20170828140927.GD10418@lunn.ch>
 <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
 <20170829074130.GA31303@amd> <20170829122604.GA22093@lunn.ch>
 <20170829211519.GA24221@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Maxim Uvarov <muvarov@gmail.com>, nathan.leigh.conrad@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@ucw.cz>, Andrew Lunn <andrew@lunn.ch>,
        Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829211519.GA24221@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/29/2017 02:15 PM, Pavel Machek wrote:
> On Tue 2017-08-29 14:26:04, Andrew Lunn wrote:
>>> But the MDIO emaulation code is from their driver, after lots of
>>> deletions.
>>
>> Is this driver supposed to run on lots of different OSs? That would
>> explain why they ignored the Linux MDIO and PHY layers.
> 
> It did not look particulary portable.

Part of the problem is that they need to duplicate the standard MII
definitions, whereas we could re-use those from include/linux/mii.h
and/or mdio.h.

> 
>> If possible, please make use of the Linux infrastructure.
> 
> I did not find any infrastructure I could use instead
> ksz_mdio_emulation.

fixed PHY/swphy.c is as close as it could get, but it is a highly
simplified version of this.

> 
> Now, drivers/net/phy/spi_ks8995.c can access the PHY registers, and I
> can not see any translation there, so there may be something I'm
> missing.

I don't see anything in that driver that seems to access PHY registers
what makes you think it does?

There's got to be a way to perform indirect accesses through SPI,
Woojung, do you know?

> 
> Pointers would be welcome at this point.
> 
> Thanks,
> 									Pavel
> 


-- 
Florian
