From: "David S. Miller" <davem@redhat.com>
Subject: Re: changing MTU on b44 breaks eth0
Date: Tue, 4 Nov 2003 13:20:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104132017.1d43a69c.davem@redhat.com>
References: <1067888106.3366.20.camel@bluez.bueche.ch>
	<20031103205335.GA7668@ee.oulu.fi>
	<20031103151618.79704b30.davem@redhat.com>
	<20031104111555.GA26860@ee.oulu.fi>
	<20031104091355.70d6a3d1.davem@redhat.com>
	<20031104211937.GA3888@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031104211937.GA3888@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2003 23:19:37 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> On Tue, Nov 04, 2003 at 09:13:55AM -0800, David S. Miller wrote:
> > free_netdev() is being invoked before the device registration
> > state advanced to NETREG_UNREGISTERED, likely unregister_netdev()
> > has not been called first or a bogus pointer was passed into
> > the routine.
> Ah, like a missing SET_NETDEV_DEV? :-)

Wonderful, Jeff please integrate this b44 patch from Pekka.
