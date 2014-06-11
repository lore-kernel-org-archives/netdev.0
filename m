From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 06/13] i40e: implement anti-spoofing for VFs
Date: Wed, 11 Jun 2014 07:37:12 -0700
Message-ID: <1402497432.2219.2.camel@jtkirshe-mobl.jf.intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZJGZNhX7yPF6MvCjW+EYi-EGJgW1GhFa5CO=myAgJj-1A@mail.gmail.com>
	 <1402488782.2306.18.camel@jtkirshe-mobl>
	 <CAJZOPZLr-QYMfQ6homSvkDfUh+np3q5qbmRNLzBgxyWjk+LONQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TBp350GVm8vrutgYDTyb"
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36356 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048AbaFKOhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 10:37:14 -0400
In-Reply-To: <CAJZOPZLr-QYMfQ6homSvkDfUh+np3q5qbmRNLzBgxyWjk+LONQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TBp350GVm8vrutgYDTyb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-06-11 at 15:43 +0300, Or Gerlitz wrote:
> On Wed, Jun 11, 2014 at 3:13 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Mon, 2014-06-09 at 22:49 +0300, Or Gerlitz wrote:
> >> On Mon, Jun 9, 2014 at 11:49 AM, Jeff Kirsher
> >> <jeffrey.t.kirsher@intel.com> wrote:
> >> > From: Mitch Williams <mitch.a.williams@intel.com>
> >> >
> >> > Our hardware supports VF antispoofing for both MAC addresses and VLA=
Ns.
> >> > Enable this feature by default for all VFs
> >>
> >> What do you expect the HW to do when spoof check is enabled (by
> >> default) but the admin didn't configure a MAC address for the VF
> >> through the PF? that is the VF is allowed to use what ever MAC they
> >> want to?
> >>
> >> > and implement the netdev op to control it from the command line.
> >
> > Here is the answer I got:
> > If the VF mac address is set within the VM and it is accepted by the PF=
,
>=20
> When the admin doesn't configure MAC address for the VM, what logic is
> applied by the PF to decide whether or not to accept a VF MAC set by the =
VM?

If the PF has not set the MAC address, it will check for a valid MAC
address that is neither broadcast or all zeros.

Look at the add_addr message handler i40e_vc_add_mac_addr_msg() or more
specifically i40e_check_vf_permission().=20

--=-TBp350GVm8vrutgYDTyb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTmGmYAAoJEOVv75VaS+3OWlYP+gJK5dVZpr8gOtwjcDtF4cTj
lpVe3q3Vswz12OkxrTdAMZntQ8nUskKw2r5KY1tlHEPnt8dyaxlJJAu43bIaeuLP
N6WVFT3hl6BuJdB/vcPvELSFyh7DUtPcuA4RMWTDASgi7XcOPiGvxW1M1zbDiPK4
c2yQCk1aw54d8J2GkjV+KHeTKmMnrXkBOClFWk+KRYxKwY2kpsZ878zbh4zEk5gS
nnlSD9UlQk+bc7BUpkOvaHbTDshZ80rhGo0NMD2ky+3VQuxgA/D7uYm7Zu4c2SI7
+Lak6wiXFlwWnSRwVk3DTYD5xMrr6YrZZXtPglNlbkqqgP2bFe0hSoDDCjyEFjc3
fSNEiLC/7UeqvWnJAn/54+UNmkYj5YGdofYCGByfq3Tm81sXOVWtmb2YI3r37aFB
K4EyI5Y3VwznVGKVsz09e2lm4IN4oYh7gvabjdEMXSlxlNcl7Y1QhMiaqGS3K8R/
7vXcbuyptxlb07Of6K7FT8eEHVQ5vlXKnu0nWD4Z+/ovicxQ35VTYLcpPkDb67Bd
5DO7VNGrb4MCh5Sr0czPtE0rQeC+Yuz3XlYrc6LLLvwf1YvA4VL2EA3HayoIEIbR
UjHI94BVup+aeLLU8GqLapKUrkgKV3H9SBrKcxmsXEd0EAUER4NtHao88ZFgioAN
DT781cBPiGJlkWI38jm1
=NMh3
-----END PGP SIGNATURE-----

--=-TBp350GVm8vrutgYDTyb--
