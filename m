From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Sat, 18 Jul 2015 17:28:35 +0200
Message-ID: <20150718152835.GF17961@lunn.ch>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150710171027.GB6585@groeck-UX31A>
 <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
 <20150710183623.GB19854@roeck-us.net>
 <645518234.216003.1436556107630.JavaMail.zimbra@savoirfairelinux.com>
 <20150710200514.GA9469@groeck-UX31A>
 <20150718145830.GA17961@lunn.ch>
 <1971016402.292095.1437232999941.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1971016402.292095.1437232999941.JavaMail.zimbra@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 18, 2015 at 11:23:19AM -0400, Vivien Didelot wrote:
> Hi all,
> 
> ----- On Jul 18, 2015, at 10:58 AM, Andrew Lunn andrew@lunn.ch wrote:
> 
> >> Good point. The timeout is most definitely quite large and for sure on
> >> the safe side. It might make sense to add some statistics gathering to
> >> see how long the maximum observed delay actually is.
> > 
> > Hi All
> > 
> > Statistics are something which can be used a lot, i bursts and
> > interactivily. ATU, VTU etc, are much less often used. So different
> > delays might be justified.
> > 
> > I agree about doing some statistics gathering to determine actual
> > delays needed.
> > 
> >        Andrew
> 
> What do you think about something like this?

Hi Vivien

Lets get some actually statistics first. I would suggest for testing
you make _mv88e6xxx_wait() a busy loop and time how long it actually
takes for different busy bits to clear. We should also test it on
different families.

	  Andrew
