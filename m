From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 30 Dec 2014 11:34:38 -0800
Message-ID: <1419968078.31582.27.camel@jtkirshe-mobl>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
		 <CAL3LdT73zfJwNcHS0ZpZ=ZzG=UiCUW5UEnOF9Fp2rR0e-ejXYg@mail.gmail.com>
		 <CAOYyTHb+5Wc-e3vBVE+MCh6YNfmompi9Mnsr0nDnHAn7Tvqyew@mail.gmail.com>
		 <1419965520.31582.20.camel@jtkirshe-mobl>
		 <CAOYyTHathHiGThyHj+yRi9O6jWEAO3wkAK-6egMc2OwK9dQoMQ@mail.gmail.com>
	 <1419967707.31582.23.camel@jtkirshe-mobl>
	 <54A2FD6C.6050807@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hcfcoWn1omU7ZY7BSt3h"
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	Gleb Natapov <gleb@cloudius-systems.com>,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:60482 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbaL3Tek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2014 14:34:40 -0500
In-Reply-To: <54A2FD6C.6050807@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hcfcoWn1omU7ZY7BSt3h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-30 at 21:30 +0200, Vlad Zolotarov wrote:
> On 12/30/14 21:28, Jeff Kirsher wrote:
> > On Tue, 2014-12-30 at 21:00 +0200, Vladislav Zolotarov wrote:
> >> On Dec 30, 2014 8:52 PM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> >> wrote:
> >>> On Tue, 2014-12-30 at 20:50 +0200, Vladislav Zolotarov wrote:
> >>>> On Dec 30, 2014 8:16 PM, "Jeff Kirsher"
> >> <jeffrey.t.kirsher@intel.com>
> >>>> wrote:
> >>>>> On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
> >>>>> <vladz@cloudius-systems.com> wrote:
> >>>>>> Add the ethtool ops to VF driver to allow querying the RSS
> >>>> indirection table
> >>>>>> and RSS Random Key.
> >>>>>>
> >>>>>>   - PF driver: Add new VF-PF channel commands.
> >>>>>>   - VF driver: Utilize these new commands and add the
> >> corresponding
> >>>>>>                ethtool callbacks.
> >>>>>>
> >>>>>> Vlad Zolotarov (5):
> >>>>>>    ixgbe: Add a RETA query command to VF-PF channel API
> >>>>>>    ixgbevf: Add a RETA query code
> >>>>>>    ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
> >>>>>>    ixgbevf: Add RSS Key query code
> >>>>>>    ixgbevf: Add the appropriate ethtool ops to query RSS
> >>>> indirection
> >>>>>>      table and key
> >>>>>>
> >>>>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
> >>>>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  60
> >>>> +++++++++++
> >>>>>>   drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37
> >> +++++++
> >>>>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
> >>>>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
> >>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.c           | 125
> >>>> ++++++++++++++++++++++
> >>>>>>   drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
> >>>>>>   7 files changed, 243 insertions(+), 1 deletion(-)
> >>>>> Remember to CC on patches against drivers in
> >>>> drivers/net/ethernet/intel/ please.
> >>>>
> >>>> To CC who? ;)
> >>>>
> >>> Sorry, I fat fingered that response.  Please CC me.
> >> Sure. NP.
> >> Since we are talking already, could u comment on the RFC? Does it look
> >> ok to you?
> >>
> >>
> > I have provided feedback on 3 of the patches, the others look ok to me.
> > I would like Greg Rose to look over your changes since he did most of
> > the ixgbevf work, and I want to make sure that he is fine with these
> > changes.
>=20
> I saw them. Thanks, Jeff. I'll wait for Greg's comments before cooking=
=20
> the final series then.
>=20
> Again, thanks for a rapid response.
>=20

Go ahead and send out a non-RFC series.  Greg is on vacation till the
5th anyway, so I will pick up your series and have my validation team
run it through their tests in the mean time.

--=-hcfcoWn1omU7ZY7BSt3h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUov5OAAoJEOVv75VaS+3OdvcP/1ufJk/TtIg0HDyp57XlKQs/
vCghO/bNr+8I9uisyjX1Biw93mkbgK3BfM/H/hIynNxoTa9uFVWLJQbBpOKtT900
OyyfU9ifAeHYmVrTnixaFnjEIgPIm6KO/L0ISUyrdDw1MrX8P2YovPBAxmrw9HjM
IcFA6OD7s118AsMyHGrT+rZDUumVCzzMluib35KaZTbP2WgURxOhrz3GvDrMpRgX
2usGyABseQcPV9bml1+Qzf3k9Bgyrw6X+VDos/QqtciE3fy3hz06IwL2pqxf3IuJ
Crb12VZ+hclOpB45sgkh767Y4oRLyvxGnrz/uOt/QLJDl9lERTHL7VoElDx+5sW3
H+uO/bmkR8DreC7Sk8onpfoffN9Yc530qUKUfvMor8O6IAVRLzG2quLP5jUI3GKV
/xDWOoMtYLEnUxU9+V9JqQ9wPS4eDwYSQmVjB9dN+JbUFAEbhG6VBut3MCt7eO4m
rMe+LhPVOTfiDMOcWCiq00d0AN5GoqW8fGI4wVDDenVmOahXRzj6YsG7GeI8ug6O
/EUZCrnlfR1QYjyoCBBZ3Ew+QJBB+emyq1l64i7SZULwbeTlvtw09w9DqmSRgnc4
zWQLlMHe3b4U2RE6LPwzpYUKlO3M6g0Ogy+a+rjG0UL5mMGWwJAEQVm0Ps7AVvlq
KwNnMKXuLpV3z5J5rPnS
=qSOo
-----END PGP SIGNATURE-----

--=-hcfcoWn1omU7ZY7BSt3h--
