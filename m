From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next RFC 3/9] net: dsa: mv88e6xxx: add support for GPIO configuration
Date: Thu, 28 Sep 2017 15:57:51 -0400
Message-ID: <87k20izjcw.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com> <1506612341-18061-4-git-send-email-brandon.streiff@ni.com> <659c4254-d0b7-52dc-dd9b-3921cd2f20c0@gmail.com> <20170928180111.GF14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928180111.GF14940@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brandon,

>> Would there be any value in implementing a proper gpiochip structure
>> here such that other pieces of SW can see this GPIO controller as a
>> provider and you can reference it from e.g: Device Tree using GPIO
>> descriptors?
>
> That would be my preference as well, or maybe a pinctrl driver.

Indeed seeing a gpio_chip or a pinctrl controller registered from a
gpio.c or pinctrl.c file in a separate patchset would be great.


Thanks,

        Vivien
