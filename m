From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/6] net: dsa: allow switch drivers to cleanup their
 resources
Date: Tue, 27 Oct 2015 12:59:32 -0400
Message-ID: <20151027165932.GA21799@ketchup.mtl.sfl>
References: <562F8ED7.2000804@baylibre.com>
 <562F9AAB.8090202@gmail.com>
 <562F9BB1.8090700@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562F9BB1.8090700@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct. Tuesday 27 (44) 04:43 PM, Neil Armstrong wrote:
> Hi,
> On 10/27/2015 04:39 PM, Florian Fainelli wrote:
> > On 27/10/15 07:48, Neil Armstrong wrote:
> >> Some switch drivers might request interrupts, remap register ranges,
> >> allow such drivers to implement a "remove" callback doing just that.
> >>
> >> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> > 
> > This should probably be a Signed-off-by tag, but there is nothing using
> > this, so you would want to introduce an user of this function in the
> > same patch series so we see how you intend to use it?
> > 
> >> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> 
> Yes, I didn't know how to handle this since it was part of a larger patch.
> 
> I forgot to add this into the cover-letter but I wanted to send an RFC serie with
> your bcm remove patch and a mv88e6xxx remove experimental code.
> 
> Yet, the mv88e6060 does not make usage of this.

So this patch must be part of your RFC for module removal instead of
this patchset.

Thanks,
-v
