From: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 25 Nov 2015 11:18:32 +0800
Message-ID: <56552888.90108@intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com> <5654722D.4010409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, agraf-l3A5Bk7waGM@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	weiyang-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5654722D.4010409-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B411=E6=9C=8824=E6=97=A5 22:20, Alexander Duyck wrote:
> I'm still not a fan of this approach.  I really feel like this is
> something that should be resolved by extending the existing PCI hot-p=
lug
> rather than trying to instrument this per driver.  Then you will get =
the
> goodness for multiple drivers and multiple OSes instead of just one. =
 An
> added advantage to dealing with this in the PCI hot-plug environment
> would be that you could then still do a hot-plug even if the guest
> didn't load a driver for the VF since you would be working with the P=
CI
> slot instead of the device itself.
>=20
> - Alex

Hi Alex:
	What's you mentioned seems the bonding driver solution.
Paper "Live Migration with Pass-through Device for Linux VM" describes
it. It does VF hotplug during migration. In order to maintain Network
connection when VF is out, it takes advantage of Linux bonding driver t=
o
switch between VF NIC and emulated NIC. But the side affects, that
requires VM to do additional configure and the performance during
switching two NIC is not good.

--=20
Best regards
Tianyu Lan
