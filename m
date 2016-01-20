From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: xen-netfront crash when detaching network while
 some network activity
Date: Wed, 20 Jan 2016 16:59:14 -0500
Message-ID: <20160120215914.GA6384@char.us.oracle.com>
References: <20150522114932.GC8664@mail-itl> <55645140.1050209@citrix.com>
	<20150526220312.GA1358@mail-itl> <20151021185734.GD31646@mail-itl>
	<20151117024515.GN976@mail-itl>
	<20151201220042.GC22107@char.us.oracle.com>
	<20151201223258.GH1337@mail-itl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Annie Li <annie.li@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	netdev@vger.kernel.org, David Vrabel <david.vrabel@citrix.com>,
	xen-devel <xen-devel@lists.xen.org>
To: Marek =?iso-8859-1?Q?Marczykowski-G=F3recki?=
	<marmarek@invisiblethingslab.com>,
	Joao Martins <joao.m.martins@oracle.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <20151201223258.GH1337@mail-itl>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2015 at 11:32:58PM +0100, Marek Marczykowski-G=F3recki wrot=
e:
> On Tue, Dec 01, 2015 at 05:00:42PM -0500, Konrad Rzeszutek Wilk wrote:
> > On Tue, Nov 17, 2015 at 03:45:15AM +0100, Marek Marczykowski-G=F3recki =
wrote:
> > > On Wed, Oct 21, 2015 at 08:57:34PM +0200, Marek Marczykowski-G=F3reck=
i wrote:
> > > > On Wed, May 27, 2015 at 12:03:12AM +0200, Marek Marczykowski-G=F3re=
cki wrote:
> > > > > On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> > > > > > On 22/05/15 12:49, Marek Marczykowski-G=F3recki wrote:
> > > > > > > Hi all,
> > > > > > > =

> > > > > > > I'm experiencing xen-netfront crash when doing xl network-det=
ach while
> > > > > > > some network activity is going on at the same time. It happen=
s only when
> > > > > > > domU has more than one vcpu. Not sure if this matters, but th=
e backend
> > > > > > > is in another domU (not dom0). I'm using Xen 4.2.2. It happen=
s on kernel
> > > > > > > 3.9.4 and 4.1-rc1 as well.
> > > > > > > =

> > > > > > > Steps to reproduce:
> > > > > > > 1. Start the domU with some network interface
> > > > > > > 2. Call there 'ping -f some-IP'
> > > > > > > 3. Call 'xl network-detach NAME 0'
> > =

> > Do you see this all the time or just on occassions?
> =

> Using above procedure - all the time.
> =

> > I tried to reproduce it and couldn't see it. Is your VM an PV or HVM?
> =

> PV, started by libvirt. This may have something to do, the problem didn't
> existed on older Xen (4.1) and started by xl. I'm not sure about kernel
> version there, but I think I've tried there 3.18 too, which has this
> problem.
> =

> But I don't see anything special in domU config file (neither backend
> nor frontend) - it may be some libvirt default. If that's really the
> cause. Can I (and how) get any useful information about that?

libvirt naturally does some libxl calls, and they may be different.

Any chance you could give me an idea of:
 - What commands you use in libvirt?
 - Do you use a bond or bridge?
 - What version of libvirt you are using?

Thanks!
CC-ing Joao just in case he has seen this.
> =

> =

> -- =

> Best Regards,
> Marek Marczykowski-G=F3recki
> Invisible Things Lab
> A: Because it messes up the order in which people normally read text.
> Q: Why is top-posting such a bad thing?
