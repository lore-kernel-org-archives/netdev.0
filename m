From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 21:45:16 +0100
Message-ID: <20050306204516.GR31837@postel.suug.ch>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch> <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Radouch <zdenek@rcn.com>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <m1y8d0mss2.fsf@muc.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andi Kleen <m1y8d0mss2.fsf@muc.de> 2005-03-06 21:19
> Zdenek Radouch <zdenek@rcn.com> writes:
> >
> > There is no doubt that the 127.x net is treated in a special
> > way.  If I have to believe what I just learned, then the 127
> 
> It is. 127.* is hardcoded in the routing engine and e.g.
> it won't accept outside packets with a loopback address.
> 
> Most likely it's enough to change the "LOOPBACK" macro to allow
> parts of the Class A to be used for other purposes.

Yes, it will work around the martian route and arp checks but
will probably break quite a few usersapce applications.
