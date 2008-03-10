From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Treason uncloaked spams syslog with latest git
Date: Mon, 10 Mar 2008 20:48:05 +0100 (CET)
Message-ID: <alpine.LFD.1.00.0803102046420.3781@apollo.tec.linutronix.de>
References: <alpine.LFD.1.00.0803061140380.3099@apollo.tec.linutronix.de> <20080306153129.e247cd1a.akpm@linux-foundation.org> <Pine.LNX.4.64.0803071547370.5423@kivilampi-30.cs.helsinki.fi> <alpine.LFD.1.00.0803072050410.3099@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-569145175-1205178487=:3781"
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755731AbYCJTsj@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.00.0803072050410.3099@apollo.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-569145175-1205178487=:3781
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Fri, 7 Mar 2008, Thomas Gleixner wrote:
> On Fri, 7 Mar 2008, Ilpo Järvinen wrote:
> > On Thu, 6 Mar 2008, Andrew Morton wrote:
> > 
> > > On Thu, 6 Mar 2008 11:47:12 +0100 (CET)
> > > Thomas Gleixner <tglx@linutronix.de> wrote:
> > > 
> > > > Since I updated one of my compile boxen to latest git I get the syslog
> > > > flooded with:
> > > > 
> > > > TCP: Treason uncloaked! Peer 192.168.0.1:10245/56637 shrinks window
> > > > 2748077551:2748080447. Repaired.
> > > > TCP: Treason uncloaked! Peer 192.168.0.68:10245/39915 shrinks window
> > > > 2890195332:2890201124. Repaired.
> > > > TCP: Treason uncloaked! Peer 192.168.0.65:10245/46058 shrinks window
> > > > 2880740873:2880745217. Repaired.
> > > > 
> > > > This happens _always_ when I compile kernels with distcc or icecc. All
> > > > systems involved run Linux with kernels >= 2.6.23 and are on the same
> > > > network; no routers, firewalls or other fancy stuff.
> > > > 
> > > > Any idea what's going on here ?
> > > > 
> > > 
> > > (cc netdev)
> > 
> > Could you tcpdump it?
> 
> Will do.

http://www.tglx.de/~tglx/treason.cap

That's on -rc5

Thanks,
	tglx
--8323328-569145175-1205178487=:3781--
