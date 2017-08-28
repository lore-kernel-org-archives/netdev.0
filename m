From: Maxim Uvarov <muvarov@gmail.com>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 17:47:05 +0300
Message-ID: <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
References: <20170816075524.GA18532@amd> <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd> <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd> <20170828140927.GD10418@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pavel Machek <pavel@ucw.cz>, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828140927.GD10418@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micrel has some drivers on their web site to support some chips. For
that chips they do virtual mdio over spi.
And driver is available on download page:
http://www.microchip.com/wwwproducts/en/KSZ8895

Documentation->Software library.

Both driver and DSA driver. Driver has to work with some minor fixups
related to your kernel version. But I think they are don't care about
up-streaming that code.
So you can take their code as a reference.

2017-08-28 17:09 GMT+03:00 Andrew Lunn <andrew@lunn.ch>:
>> I may be confused here, but AFAICT:
>>
>> 1) Yes, it has standard layout when accessed over MDIO.
>
>
> Section 4.8 of the datasheet says:
>
>         All the registers defined in this section can be also accessed
>         via the SPI interface.
>
> Meaning all PHY registers can be access via the SPI interface. So you
> should be able to make a standard Linux MDIO bus driver which performs
> SPI reads.
>
>     Andrew

Micrel has some drivers on their web site to support some chips. For
that chips they do virtual mdio over spi.
And driver is available on download page:
http://www.microchip.com/wwwproducts/en/KSZ8895

Documentation->Software library.

Both driver and DSA driver. Driver has to work with some minor fixups
related to your kernel version. But I think they are don't care about
up-streaming that code.
So you can take their code as a reference.

-- 
Best regards,
Maxim Uvarov
