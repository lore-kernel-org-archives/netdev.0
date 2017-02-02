From: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the
 DP83867 TI's PHY driver
Date: Thu, 2 Feb 2017 16:22:12 +0100
Message-ID: <20170202162212.4d479fa5@jawa>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
        <20170201171610.GC7395@lunn.ch>
        <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
        <20170201220500.29d478aa@jawa>
        <20170201211440.GG7395@lunn.ch>
        <20170201231323.732dd327@jawa>
        <20170202015416.GG4967@lunn.ch>
        <20170202101739.67e7e6b3@jawa>
        <20170202131112.GI4967@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Karicheri Muralidharan <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170202131112.GI4967-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Feb 2017 14:11:12 +0100
Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:

> > The bootstrapping process in the PHY sets this bit. This is wrong
> > since the board lane layout is not "swapped"
>  
> Ah, you mean a strapping pin? Resistor to ground/VCC?

Yes, exactly.

> That is a different matter. It makes it a lot less likely to break
> some existing board with such a change.
> 
> > I have thought a bit about that and I think that we should define
> > complementary "net-phy-lane-no-swap" as suggested by Florian. Then
> > affected boards could define it and use.
> 
> This is the most flexible solution. Yes, that is O.K. for me.

Ok. thanks.

> 
>      Andrew




Best regards,

Lukasz Majewski

--

DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd-ynQEQJNshbs@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
