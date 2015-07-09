From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Add support for Marvell
 88E6320 and 88E6321
Date: Thu, 9 Jul 2015 11:26:25 -0700
Message-ID: <20150709182625.GB788@roeck-us.net>
References: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
 <1436432003.20619.102.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"Aleksey S. Kazantsev" <ioctl@yandex.ru>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436432003.20619.102.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 09, 2015 at 10:53:23AM +0200, Paul Bolle wrote:
> On di, 2015-07-07 at 20:38 -0700, Guenter Roeck wrote:
> > --- a/drivers/net/dsa/mv88e6352.c
> > +++ b/drivers/net/dsa/mv88e6352.c
>  
> > -MODULE_ALIAS("platform:mv88e6352");
> >  MODULE_ALIAS("platform:mv88e6172");
> > +MODULE_ALIAS("platform:mv88e6176");
> > +MODULE_ALIAS("platform:mv88e6320");
> > +MODULE_ALIAS("platform:mv88e6321");
> > +MODULE_ALIAS("platform:mv88e6352");
> 
> Naive question: there are quite a few similar MODULE_ALIAS() macros in
> drivers/net/dsa. That is, macros using "platform:mv88e6[...]". But I
> couldn't find the struct platform_device's that would, in short, fire
> off the corresponding "MODALIAS=platform:mv88e6[...]" uevent when
> they're created. Where should I look for those struct platform_device's?
> 
Good question. The devices are instantiated from the dsa driver
(net/dsa/dsa.c). I don't really know if the above aliases serve
a practical purpose.  Does anyone else know ?

Guenter
