From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [patch 1/8]  irda/act200l-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 1 Sep 2004 14:48:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901214815.GA13071@bougret.hpl.hp.com>
References: <E1C2cIF-0007yy-Lb@sputnik> <20040901210929.GA11442@bougret.hpl.hp.com> <20040901214003.GC7467@stro.at>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com, kj <kernel-janitors@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040901214003.GC7467@stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2004 at 11:40:03PM +0200, maximilian attems wrote:
> On Wed, 01 Sep 2004, Jean Tourrilhes wrote:
> 
> > On Wed, Sep 01, 2004 at 11:05:23PM +0200, janitor@sternwelten.at wrote:
> > > I would appreciate any comments from the janitor@sternweltens list. 
> uups mangled some text there sorry for this silly email.
> > 
> > 	I already commented that I don't like the confusing msleep()
> > API and I prefer the more explicit schedule_timeout().
> > 	But that's only me...
> > 
> > 	Jean
> 
> hmm we have still archs were HZ < 100.
> i find msleep use msecs units a lot more readable than
> 	schedule_timeout((HZ + 99) / 100);
> 
> the schedule_timeout(HZ/100) gets safely converted with msleep.

	I don't have complain about converting the (HZ + 99) / 100
expressions to something saner. My beef is the fact that msleep hide
the fact that a schedule might happen. This is important in the IrDA
code.

> maks

	Jean
