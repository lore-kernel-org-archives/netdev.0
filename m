From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/21] ARCNET: Defibrillation
Date: Wed, 29 Apr 2015 20:49:25 -0700
Message-ID: <1430365765.2575.5.camel@perches.com>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	 <1429901273.23327.5.camel@perches.com> <553AB241.3080004@pengutronix.de>
	 <20150424.235853.1997287895150693202.davem@davemloft.net>
	 <20150427145715.GC23151@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mkl@pengutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <mgr@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150427145715.GC23151@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-04-27 at 16:57 +0200, Michael Grzeschik wrote:
> Hi!
> 
> On Fri, Apr 24, 2015 at 11:58:53PM -0400, David Miller wrote:
> > From: Marc Kleine-Budde <mkl@pengutronix.de>
> > Date: Fri, 24 Apr 2015 23:14:41 +0200
> > 
> > > On 04/24/2015 08:47 PM, Joe Perches wrote:
> > >> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
> > >>> Hi!
> > >> 
> > >> Hello.
> > >> 
> > >>> This patch series tries to reanimate the ARCNET hardware layer to be
> > >>> somehow readable and maintainable again. It includes a lot of cleanup
> > >>> patches. It also adds some fixes which leads the layer to become usable
> > >>> again. And as a special treatment it adds more features like correct
> > >>> loading and unloading of the com20020 card.
> > >> 
> > >> Wow.  Good for you, but why?  Does anyone still use these?
> > > 
> > > Yes, there are parts of the industry where "old" machines are
> > > retrofitted with new hardware...and a lot of these machines still talk
> > > ARCNET :)
> > 
> > But the real issue is, this layer is development wise in the same
> > category as the IDE layer.
> > 
> > Any non-trivial change is nothing but pure risk, especially given the
> > low level of test coverage the code gets.
> 
> Do you count coding style patches as non-trivial or trivial
> patches?
> 
> > So I really only want to see the most critical obvious bug fixes
> > submitted for this layer and drivers.
> 
> The cleanup changes I submitted should not change the actual behaviour.
> Replacing the register access macros with their equivalent outb/inb
> seems pretty obvious. What is your opinion on those?
> 
> I see that the "ARCNET: whitespace, tab and codingstyle fixes" patch is
> pretty mixed up and not very reliable. But Joe has sent me a nice series
> for the cleanup.
> 
> > And no I will not accept an argument stating that you have to
> > restructure and clean this code up in order to fix the bugs.  That's
> > bogus.
> 
> OK.
> 
> I have the following patches in this series which fix bugs found during
> my development:
> 
> com20020-pci: add dev_port for udev handling
> ARCNET: fix hard_header_len limit
> ARCNET: com20020: add enable and disable device on open/close
> 
> I would send a new series containing only those patches with more
> detailed patch descriptions, if that's fine with you?

I was away for a few days and while out I did another
restructuring of all the inb/outb/readb/writeb code
removing all the A<FOO> macros.  It removes all the
dependencies on ioaddr and names all the offsets with
new defines.

I could post if you like.

I think it's a lot cleaner and easier to read.
