From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 10:38:47 +0900
Message-ID: <20100831013847.GA30077@verge.net.au>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
 <20100830183328.GI7629@nicira.com>
 <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
 <20100830205907.GM30129@sequoia.sous-sol.org>
 <20100831004827.GE11594@verge.net.au>
 <20100831005410.GB30129@sequoia.sous-sol.org>
 <20100831010103.GH11594@verge.net.au>
 <AANLkTi=ha40tm5TJUg+1seRG83Yq1h9DGm=YGyyd+-Ex@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Wright <chrisw@sous-sol.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57043 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468Ab0HaBix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 21:38:53 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=ha40tm5TJUg+1seRG83Yq1h9DGm=YGyyd+-Ex@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 06:11:30PM -0700, Jesse Gross wrote:
> On Mon, Aug 30, 2010 at 6:01 PM, Simon Horman <horms@verge.net.au> wr=
ote:
> > On Mon, Aug 30, 2010 at 05:54:10PM -0700, Chris Wright wrote:
> >> * Simon Horman (horms@verge.net.au) wrote:
> >> > On Mon, Aug 30, 2010 at 01:59:07PM -0700, Chris Wright wrote:
> >> > > * Rose, Gregory V (gregory.v.rose@intel.com) wrote:
> >> > > > >From: Ben Pfaff [mailto:blp@nicira.com]
> >> > > > >On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V w=
rote:
> >> > > > >> I just want to put in a plug for the netlink interface. =C2=
=A0For NICs with
> >> > > > >> EVB we'll need it.
> >> > > > >
> >> > > > >Off-hand, the main reasons to use Netlink, instead of the e=
xisting
> >> > > > >character device interface, are that Netlink is easier to e=
xtend and
> >> > > > >that it should reduce or eliminate the 32-to-64 bit compat =
layer
> >> > > > >currently in the Open vSwitch tree.
> >> > >
> >> > > That, plus it's a typical way to do network configuration. =C2=
=A0Esp. with
> >> > > bi-directional communication. =C2=A0So the userspace bit both =
listens to
> >> > > netlink messages, like any of the routing daemons or lldpad or=
 similar
> >> > > do, and sends netlink messasges to update driver's flow table.
> >> > >
> >> > > BTW, this kind of discussion was why Herbert felt strongly aga=
inst
> >> > > drivers/staging/. =C2=A0He wanted to be sure the interfaces we=
re well-defined
> >> > > first.
> >> >
> >> > Is the implication that there is a preference for finalising
> >> > the interface (as much as that is possible) before merging?
> >>
> >> I'll let Herbert chime in, just reminder that was his thought earl=
ier
> >> this month at LinuxCon.
> >
> > Thanks, I must confess that had slipped my mind.
>=20
> I think it might be worth delaying the merge until we at least have a
> starting point.  As the userspace interface is such an important
> aspect of the code, I don't want to ask people to review code that is
> expected to undergo a large change soon (obviously comments are alway=
s
> welcome at any time).  It's probably also more productive to have a
> discussion about minor improvements to a proposed interface than a
> free-for-all.
>=20
> As Ben mentioned, he's working on designing a Netlink-based interface
> now.  It shouldn't take too long to get a first cut out the door so
> we'll have something concrete to discuss.  I'll certainly be the firs=
t
> one to promote the different uses that are possible with Open vSwitch
> but I don't want too get bogged down in the details of future feature=
s
> now.  As long as the interface doesn't have serious problems
> precluding future work, we can merge the existing code and then move
> onto new things.

That sounds entirely reasonable.

