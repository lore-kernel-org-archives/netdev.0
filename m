From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remaining bits for basic support of LDP
Date: Tue, 3 Feb 2009 12:21:38 +0000
Message-ID: <20090203122138.GA9148@n2100.arm.linux.org.uk>
References: <20090203081042.GA4220@n2100.arm.linux.org.uk> <OF4F840E52.4A9545A8-ON80257552.003BBA78-80257552.003CC882@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, Tony Lindgren <tony@atomide.com>
To: Steve.Glendinning@smsc.com
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF4F840E52.4A9545A8-ON80257552.003BBA78-80257552.003CC882@smsc.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2009 at 11:02:31AM +0000, Steve.Glendinning@smsc.com wrote:
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 03/02/2009 
> 08:10:42:
> > On Mon, Feb 02, 2009 at 03:57:45PM -0800, Tony Lindgren wrote:
> > > * David Miller <davem@davemloft.net> [090202 13:45]:
> > > > Well, the SMSC driver is there already in the tree.
> > > > 
> > > > The only thing not currently being scheduled to hit
> > > > 2.6.29-rcX are the recent changes to support platform
> > > > specified interrupt flags and all of that stuff.
> > > > 
> > > > If you want, we can look into pushing that work into
> > > > 2.6.29-rcX
> > > 
> > > That would be great, more platforms to test it on.
> > 
> > Mainline during the -rc series is not for pushing stuff to get 
> additional
> > testing.  It's for resolving regressions and fixing bugs, not 
> introducing
> > changes which could cause regressions and bugs.
> 
> Does it help that the smsc911x driver is new this cycle?

No.

> Without these patches the driver fails to register its interrupt on many 
> arm platforms, so it could be said that these patches do fix regressions 
> against the smc911x driver it's intended to replace.

As far as I'm aware, the smc911x driver works as is on the majority of
ARM platforms.  The fact that it works is enough justification to leave
well alone during the -rc series.

Changing it involves risk that something will break, which will cause
a regression.  This is not a risk that we want, and we certainly don't
want any new regressions in the -rc series.  The proper time to take
that risk is during the merge window.

> On a related note, if these go in during the next merge window, is there a 
> mechanism for ensuring the platform support patches in the set are merged 
> after these?

No, and that's the problem with splitting it across two separate trees,
which is a point I was trying to make when these patches first came to
my attention.
