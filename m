From: jamal <hadi@cyberus.ca>
Subject: Re: Level One LXT1001 GE chip
Date: 27 Nov 2003 08:52:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069941123.1027.6.camel@jzny.localdomain>
References: <3FC3FB99.70700@wanadoo.es>
	 <20031127010324.061cac3b.davem@redhat.com>
	 <20031127122021.3ac80a86.ak@suse.de>  <20031127122642.046d07ce.ak@suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, xose@wanadoo.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031127122642.046d07ce.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The reading of CSR32 equating to clearing it makes it a little pathetic.
I like the fact that reading that register also disables interupts
because that makes it NAPI friendly.
If you are NAPIizing it then the only style you could use is in the wat
the e1000 is done.
Andi, is this the driver you were playing those neat tricks with
getting rid of some of the nastiness in eth_type_trans()?

cheers,
jamal

On Thu, 2003-11-27 at 06:26, Andi Kleen wrote:

> > 
> > Actually there is an old vendor driver for the lxt1001
> > (but it is quite ugly and will probably need some porting for 2.6
> > or even 2.4) 
> > 
> > I've been also slowly working on a new driver, but still nothing
> > releasable.
> 
> BTW I should add - the chipset is really dead. Intel has bought
> LevelOne and killed it.  You are unlikely to be able to get any 
> new cards for it.  But it is an quite interesting architecture
> (with some complete stupidity and some interesting features) and rather
> different from a classic Tulip/AMD like network card.
> 
> -Andi
> 
> 
