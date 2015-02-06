From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Ethernet: how to disable gigabit support
Date: Fri, 6 Feb 2015 14:57:06 +0100
Message-ID: <20150206135706.GB25683@amd>
References: <20150205202527.GA7917@amd>
 <54D3F267.3000908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54D3F267.3000908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2015-02-05 14:44:55, Florian Fainelli wrote:
> On 05/02/15 12:25, Pavel Machek wrote:
> > Hi!
> > 
> > This happened on more than one project: there's gigabit-capable chip,
> > but the connector is not designed for gigabit speed.
> > 
> > I'd like to have speed autonegotiation, but not offer gigabit (as it
> > will not work).
> > 
> > Is there way to do that without hacking the kernel? Should mii-tool do
> > that?
> 
> Since you use the PHY library, you should be able to do something like
> this in your PHY driver prior to starting the PHY state machine:
> 
> phydev->supported &= PHY_BASIC_FEATURES (effectively masking Gigabit
> capability)

Thanks, that did the trick.
								Pavel
(But still it would be nice to have a generic way of doing this,
using something like mii-tool.)

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
