From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 1/3 v2] [E1000-devel] [rfc 1/4] igb: Add igb_cleanup_vf()
Date: Thu, 26 Nov 2009 09:11:46 +1100
Message-ID: <20091125221146.GI4794@verge.net.au>
References: <20091125063213.203372240@vergenet.net>
 <20091125063530.796967189@vergenet.net>
 <9929d2390911242340t2e639719kc5ed80725f74a31d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36811 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759013AbZKYWLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 17:11:41 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390911242340t2e639719kc5ed80725f74a31d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 11:40:36PM -0800, Jeff Kirsher wrote:
> On Tue, Nov 24, 2009 at 22:32, Simon Horman <horms@verge.net.au> wrot=
e:
> > Move virtual finction cleanup code into igb_cleanup_vf() and for th=
e sake
> > of symmetry rename igb_probe_vfs() as igb_init_vf().
> >
> > Although these functions aren't entirely symmetrical it should aid
> > maintenance by making the relationship between initialisation and c=
leanup
> > more obvious.
> >
> > Note that there appears to be no way for adapter->vfs_allocated_cou=
nt to be
> > non-zero for the case where CONFIG_PCI_IOV is not set, so reseting =
this
> > value was moved to inside the relvant #ifdef.
> >
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> > ---
> > Thu, 05 Nov 2009 11:58:48 +1100
> > * Initial post
> >
> > Wed, 25 Nov 2009 15:43:45 +1100
> > * Actually remove adapter->vfs_allocated_count =3D 0 from outside o=
f
> > =C2=A0igb_cleanup_vf()
> > * Up-port to current net-next
>=20
> Thanks Simon and congrats on the new addition!  I have added this
> three patch series to my tree for review and testing.

Thanks
