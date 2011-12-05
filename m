From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 05 Dec 2011 00:24:58 -0800
Message-ID: <1323073499.24828.36.camel@jtkirshe-mobl>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111203.222659.277419094309941060.davem@davemloft.net>
	 <1322983717.24828.8.camel@jtkirshe-mobl>
	 <4EDC18D3.4060900@linux.vnet.ibm.com>
	 <1323066318.24828.14.camel@jtkirshe-mobl>
	 <4EDC6F76.2090504@linux.vnet.ibm.com>
	 <1323072138.24828.32.camel@jtkirshe-mobl>
	 <4EDC7E66.8070404@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ArvIfDHp+NCKsJBVXJOJ"
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:42643 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376Ab1LEIZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:25:00 -0500
In-Reply-To: <4EDC7E66.8070404@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ArvIfDHp+NCKsJBVXJOJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-12-05 at 00:18 -0800, Michael Wang wrote:
> On 12/05/2011 04:02 PM, Jeff Kirsher wrote:
>=20
> > On Sun, 2011-12-04 at 23:15 -0800, Michael Wang wrote:
> >> On 12/05/2011 02:25 PM, Jeff Kirsher wrote:
> >>
> >>> On Sun, 2011-12-04 at 17:05 -0800, Michael Wang wrote:
> >>>> On 12/04/2011 03:28 PM, Jeff Kirsher wrote:
> >>>>
> >>>>> On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
> >>>>>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>>>>> Date: Sat,  3 Dec 2011 03:44:26 -0800
> >>>>>>
> >>>>>>> +	if ((!adapter->tx_hang_recheck) &&
> >>>>>>
> >>>>>> Excessive parenthesis, please remove.
> >>>>>>
> >>>>>>> +		adapter->tx_hang_recheck =3D 1;
> >>>>>>
> >>>>>> This variable is a bool, set it to true or false.
> >>>>>>
> >>>>>>> +			adapter->tx_hang_recheck =3D 0;
> >>>>>>
> >>>>>> Likewise.
> >>>>>>
> >>>>>>> +	adapter->tx_hang_recheck =3D 0;
> >>>>>>
> >>>>>> Likewise.
> >>>>>
> >>>>> Michael/Flavio -
> >>>>>
> >>>>> To expedite this patch, I can make the changes that Dave is request=
ing
> >>>>> and re-submit v2 of the patch, if that is ok with you.
> >>>>>
> >>>>
> >>>> Hi, Jeff
> >>>>
> >>>> That's ok for me, I think it's good if you can work with Dave and ma=
ke
> >>>> out a final version for us, if you want my help, please mail me at a=
ny
> >>>> time, I'm glad to work with you.
> >>>>
> >>>> Flavio:
> >>>> What's your opinion?
> >>>>
> >>>> Thanks,
> >>>> Michael Wang
> >>>
> >>> I have the patch read to push, so I will go ahead an push v2 out
> >>> tonight.  Since I am making changes to your patch, I will be removing
> >>> your signed-off-by (and Flavio's) and keep you as a CC: so that you c=
an
> >>> verify the changes I have made to resolve the issues that Dave saw.
> >>>
> >>
> >> Hi, Jeff
> >>
> >> Is that means you have a better patch which different from ours, and y=
ou
> >> will use your patch to instead of ours?
> >>
> >> Because David is just ask for some small change, I think your time zon=
e
> >> may be better to work with him, so I ask for your help.
> >>
> >> I was just confused that why our signed-off-by should be removed?
> >>
> >> Thanks,
> >> Michael Wang
> >>
> >>> Cheers,
> >>> Jeff
> >=20
> > It is your patch (your original work) but since I have made changes to
> > your patch, I (or anyone for that matter) should not assume that you as
> > the owner would signed off on the changes that I have made based on
> > feedback.  It would not be right for me to send out a patch with your
> > signed-off-by which is different from what you originally submitted,
> > without your ok.  Once I send out the v2 of the patch, please feel free
> > to add your signed-off-by OR acked-by to the patch.
> >=20
>=20
> Hi, Jeff
>=20
> That make sense, I'm sorry but because I'm new to the community, and I
> just want to make every thing clear so I can do better in the future.

No problem, just trying to help get your work/fix upstream.
>=20
> > While I personally do not have a problem keeping you as the owner and
> > your signed-off-by, I believe that takes in several assumptions which
> > only you as the owner should speak for.  I am not trying to take
> > ownership for stats purposes, I care less about the number of patches I
> > create and own and would rather make sure that the original owners get
> > the credit due for the work they did.
> >=20
>=20
>=20
> I'm so sorry and I regret if I make you unhappy by some wrong word,
> please forgive me.

Not at all, you have not made me unhappy, so no need to apologize.  I am
just sorry if my email came across frustrated or unhappy.

>=20
> > So with that, when I send out my next series of patches please feel fre=
e
> > to ACK or Sign-off on the changes made.  I just wanted to make sure tha=
t
> > we get these changes in soon (with out delay).
> >=20
> > I can wait if you want to keep ownership of the patch, I just wanted to
> > ensure that we get your patch included as soon as possible based on the
> > problem it fixes.
>=20
> Please help us to make the patch perfect, and I'm very glad if I can
> have the opportunity to work with you.

I am always here to help and welcome any submissions you want to provide
to make our Intel drivers better.  Thank you!

>=20
> Thanks & Best regards
> Michael Wang
>=20



--=-ArvIfDHp+NCKsJBVXJOJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3H/aAAoJEOVv75VaS+3OmvEP/2uavGbVwb7L8SlX5A3F/kSi
J9OLxuoTKvmFo4mSnd0DutoWCNmXZ3fXcZHLAND29UvW76K8cYCzb0ZCaiv0FOW1
hYEr4Co0qQ2AtulVPB6k7NXiKU/8SQLXqDQFE/lYHoYbCm/kfLzuoho+5kDxvmwt
kr3CTsG4E2YhaGqyrCNAqALrmZn+xmlKjZhmQnLR/4tlu3lfI2MzuasE/keC1pVI
1bifXH0OTu/erqrhKx5oY06UDu2ywW4GEPCLt54Eu/lU9xmEQxTDVCe+qhS8LrKi
Vl+QrZjFhknMvY0KJ6+XEwWCW2rNx/f3fvMTJ/r9SkByHnPC9RyWDeuHYPJnvbys
TO68L4qrst2/hPHwWhjqucp97xnFn7bj1MMHXdJ4P0f3uCrl0H+wEYBQQEZcRcF3
ZwitjixXL5VizoO+mtCusr80orqDxEq3c/jYtRwWGQ+cBLHtJqqOmbjHvtcUBhGj
D1l+9B0i3Qmr+zh9AwH599HWSMUAMVWLBNbgJxco6WENxzq3VfyHacmRkf/dD0Hu
0TL4u/lpL//v/kxKabwuiunrixWUxGsx+rBWfwuaiQI905LViME43V+VCWhC94Rf
y93atIAqIVMfydoVGQ8SGYMZch1u89H5AtK6X4as1CIyqqfQoI4/eZNzOvIQwbPw
olD5m4AlG6B8CHIMfwZv
=JftL
-----END PGP SIGNATURE-----

--=-ArvIfDHp+NCKsJBVXJOJ--
