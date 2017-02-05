From: Lukasz Majewski <lukma@denx.de>
Subject: Re: [PATCH v2 1/2] net: phy: dp83867: Port mirroring support in the
 DP83867 TI's PHY driver
Date: Sun, 5 Feb 2017 15:32:19 +0100
Message-ID: <20170205153219.570425df@jawa>
References: <1486224132-15420-1-git-send-email-lukma@denx.de>
        <20170204173256.GB8364@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170204173256.GB8364@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> On Sat, Feb 04, 2017 at 05:02:11PM +0100, Lukasz Majewski wrote:
> > This patch adds support for enabling or disabling the port
> > mirroring (at CFG4 register) feature of the DP83867 TI's PHY device.
> 
> As we discussed before, "port mirroring" is bad naming. Yes, we should
> use it, because that is what the datasheet calls this feature.

That was my goal - to use naming from datasheet.

> But the
> commit message should also contain a description of what this means,
> and reference that the linux name for this concept is lane swapping.

Ok. No problem with that.

> 
> > +enum {
> 
> Maybe give the 0 value a name. DP83867_PORT_MIRROING_KEEP?

I can add this - no problem.

> 
> > +	DP83867_PORT_MIRROING_EN = 1,
> > +	DP83867_PORT_MIRROING_DIS,
> > +};
> > +
> 
> That extra enum value can then make this more obvious:
>   
>         if (dp83867->port_mirroring != DP83867_PORT_MIRROING_KEEP)
> 		dp83867_config_port_mirroring(phydev);
> 
> On the first reading of the patch, i though you were setting mirroring
> on/off under all conditions, but in fact you don't. This makes it
> clearer.

Ok. I see your point.

> 
> 	Thanks
> 		Andrew

Thanks for review :-)


Best regards,

Lukasz Majewski

--

DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
