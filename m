From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code
 optional
Date: Fri, 2 Sep 2016 19:19:20 +0200
Message-ID: <20160902171920.GP16864@lunn.ch>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
 <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com>
 <20160902145511.GH16864@lunn.ch>
 <87k2eugwcs.fsf@ketchup.mtl.sfl>
 <20160902161148.GK16864@lunn.ch>
 <87vayens26.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87vayens26.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I agree. Does the following snippet looks OK?
> 
> 
>     #ifndef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
>             if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_GLOBAL2)) {
>                     dev_err(chip->dev, "Missing support for Global 2 registers\n");

I would include the name of the option which needs enabling. Also it
is not really missing. It has not been enabled.

"The required compile time options needed to support this switch have
not been enabled. Please enable: CONFIG_NET_DSA_MV88E6XXX_GLOBAL2"

  Andrew
