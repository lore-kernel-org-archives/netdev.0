From: rask@sygehus.dk (Rask Ingemann Lambertsen)
Subject: Re:  Is a driver allowed to modify dev->flags?
Date: Tue, 1 Apr 2003 19:40:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3383.14929181269$1049220831@news.gmane.org>
References: <Pine.LNX.4.44.0304011213380.1685-100000@beohost.scyld.com>
Reply-To: rask@sygehus.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Donald Becker wrote:
> On Tue, 1 Apr 2003, Rask Ingemann Lambertsen wrote:
> 
> > Is a network device driver allowed to modify dev->flags? For example:
> >
> > if (dev->flags & IFF_ALLMULTI)
> >         dev->flags |= IFF_PROMISC;
> 
> You must be looking at the atp.c driver, or a driver that cribbed from
> it.  (Is anyone still running a parallel port Ethernet device?!)

No, but I've seen such code in other Ethernet drivers and adopted it for my NE3200 driver.

> > I've found it to cause the IFF_PROMISC flag to stick when using
> > "tcpdump -p", which to my surprice sets the IFF_ALLMULTI flag.
> 
> Which driver are you using?

My experimental NE3200 driver, linux 2.4.20 and tcpdump from Redhat 7.3.

Regards,
Rask Ingemann Lambertsen
