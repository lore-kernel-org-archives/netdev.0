From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 22:50:11 +0100
Message-ID: <20050306215011.GS31837@postel.suug.ch>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net> <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch> <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <20050306204516.GR31837@postel.suug.ch> <20050306213047.GA65970@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Radouch <zdenek@rcn.com>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050306213047.GA65970@muc.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andi Kleen <20050306213047.GA65970@muc.de> 2005-03-06 22:30
> On Sun, Mar 06, 2005 at 09:45:16PM +0100, Thomas Graf wrote:
> > Yes, it will work around the martian route and arp checks but
> > will probably break quite a few usersapce applications.
> 
> Unlikely. glibc has an own LOOPBACK() and all modern distributions
> use separate kernel/user headers anyways.

I was rather referring to the reduced loopback scope. I'm aware of
at least 3 applications that make extensive use of big portions of
the scope to multiplex streams and they depend on LOOPBACK() to make
sure the addresses they use will be looped back.

I agree that userspace has its own LOOPBACK macro in most cases but
this is exactly the problem, it may result in userspace assuming
certain addreses to be regarded as loopback by the kernel when they
won't. This of course heavily depends on how the LOOPBACK macro is
changed. I just wanted to point out that it may affect userspace
under certain circumstances.
