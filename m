From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Fri, 30 Oct 2015 17:30:07 +0100
Message-ID: <20151030163007.GB8940@lunn.ch>
References: <56321DA1.4060304@baylibre.com>
 <20151029135156.GQ2307@lunn.ch>
 <563228C3.6010501@baylibre.com>
 <20151029144012.GT2307@lunn.ch>
 <20151029145234.GB21131@ketchup.mtl.sfl>
 <20151029152802.GX2307@lunn.ch>
 <5633904D.6060108@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5633904D.6060108@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 04:44:13PM +0100, Neil Armstrong wrote:
> On 10/29/2015 04:28 PM, Andrew Lunn wrote:
> >> Is 6060 supported by the 6352 family? It doesn't share any mv88e6xxx
> >> code...
> > 
> > It is a totally separate driver. Nothing shared at all..  It is an old
> > device, and only does 10/100. It could be it is just too different to
> > support via mv88e6xxx.
> > 
> >    Andrew
> > 
> 
> Andrew,
> 
> The link detection still works without the polling for 6060, this will largely simplify the patchset.
> 
> I will include a link poll callback removal in my 6060 cleanup patchset.
> 
> Then I will include a poll_link removal in dsa.c instead of fixing it.

Great, always nice to see unneeded code removed.

       Andrew
