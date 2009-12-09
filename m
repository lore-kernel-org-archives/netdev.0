From: Johannes Stezenbach <js@sig21.net>
Subject: Re: Q: netdev: generate kobject uevent on network events.
Date: Wed, 9 Dec 2009 22:03:03 +0100
Message-ID: <20091209210303.GA24522@sig21.net>
References: <20091209170251.GA11650@sig21.net>
 <ac3eb2510912091046g4e5173b1sb97d6a4dddfd0b81@mail.gmail.com>
 <1260386486.28042.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260386486.28042.6.camel@localhost.localdomain>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 09, 2009 at 11:21:26AM -0800, Dan Williams wrote:
> On Wed, 2009-12-09 at 19:46 +0100, Kay Sievers wrote:
> > 
> > Can't, in some setups, these events happen at a rather high frequency?
> > I heard of people running many hundreds of ppp interfaces on a single
> > box acting as a DSL concentrator. They state to already have trouble
> > handling the amount of uevents generated on such boxes just for the
> > "add/remove" events of all the interfaces if something goes wrong with
> > the network. If we add more for state transitions, such events would
> > probably need to be rate-limited. In general, uevents/udev are not
> > really suitable for high-frequency events, and if such behavior can be
> > expected, we might better stick with the current netlink interface.
> 
> And then lets direct energy towards making the netlink interface simpler
> for app writers.  Either by fixing up libnl to be dead-simple to use, or
> some other mechanism.  Let's fix the *actual* problem (netlink is hard
> to use from shell scripts) instead of creating more interfaces that work
> around it.  Or maybe shellscripts are simply the wrong tool for this
> job?

Hm, yeah, I liked the simplicity of the uevent patch, but I see
it doesn't work for everyone.

BTW, I just saw that a current busybox version (1.15+) has
an iflugd applet, which uses a mix of (open coded) netlink
and polling via various socket ioctls.
http://git.busybox.net/busybox/tree/networking/ifplugd.c


Thanks,
Johannes
