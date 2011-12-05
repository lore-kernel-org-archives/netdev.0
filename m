From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 05 Dec 2011 00:02:17 -0800
Message-ID: <1323072138.24828.32.camel@jtkirshe-mobl>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111203.222659.277419094309941060.davem@davemloft.net>
	 <1322983717.24828.8.camel@jtkirshe-mobl>
	 <4EDC18D3.4060900@linux.vnet.ibm.com>
	 <1323066318.24828.14.camel@jtkirshe-mobl>
	 <4EDC6F76.2090504@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cvNNgoliNaK4I4ddV4MT"
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21943 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752482Ab1LEICT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 03:02:19 -0500
In-Reply-To: <4EDC6F76.2090504@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cvNNgoliNaK4I4ddV4MT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-12-04 at 23:15 -0800, Michael Wang wrote:
> On 12/05/2011 02:25 PM, Jeff Kirsher wrote:
>=20
> > On Sun, 2011-12-04 at 17:05 -0800, Michael Wang wrote:
> >> On 12/04/2011 03:28 PM, Jeff Kirsher wrote:
> >>
> >>> On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
> >>>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>>> Date: Sat,  3 Dec 2011 03:44:26 -0800
> >>>>
> >>>>> +	if ((!adapter->tx_hang_recheck) &&
> >>>>
> >>>> Excessive parenthesis, please remove.
> >>>>
> >>>>> +		adapter->tx_hang_recheck =3D 1;
> >>>>
> >>>> This variable is a bool, set it to true or false.
> >>>>
> >>>>> +			adapter->tx_hang_recheck =3D 0;
> >>>>
> >>>> Likewise.
> >>>>
> >>>>> +	adapter->tx_hang_recheck =3D 0;
> >>>>
> >>>> Likewise.
> >>>
> >>> Michael/Flavio -
> >>>
> >>> To expedite this patch, I can make the changes that Dave is requestin=
g
> >>> and re-submit v2 of the patch, if that is ok with you.
> >>>
> >>
> >> Hi, Jeff
> >>
> >> That's ok for me, I think it's good if you can work with Dave and make
> >> out a final version for us, if you want my help, please mail me at any
> >> time, I'm glad to work with you.
> >>
> >> Flavio:
> >> What's your opinion?
> >>
> >> Thanks,
> >> Michael Wang
> >=20
> > I have the patch read to push, so I will go ahead an push v2 out
> > tonight.  Since I am making changes to your patch, I will be removing
> > your signed-off-by (and Flavio's) and keep you as a CC: so that you can
> > verify the changes I have made to resolve the issues that Dave saw.
> >=20
>=20
> Hi, Jeff
>=20
> Is that means you have a better patch which different from ours, and you
> will use your patch to instead of ours?
>=20
> Because David is just ask for some small change, I think your time zone
> may be better to work with him, so I ask for your help.
>=20
> I was just confused that why our signed-off-by should be removed?
>=20
> Thanks,
> Michael Wang
>=20
> > Cheers,
> > Jeff

It is your patch (your original work) but since I have made changes to
your patch, I (or anyone for that matter) should not assume that you as
the owner would signed off on the changes that I have made based on
feedback.  It would not be right for me to send out a patch with your
signed-off-by which is different from what you originally submitted,
without your ok.  Once I send out the v2 of the patch, please feel free
to add your signed-off-by OR acked-by to the patch.

While I personally do not have a problem keeping you as the owner and
your signed-off-by, I believe that takes in several assumptions which
only you as the owner should speak for.  I am not trying to take
ownership for stats purposes, I care less about the number of patches I
create and own and would rather make sure that the original owners get
the credit due for the work they did.

So with that, when I send out my next series of patches please feel free
to ACK or Sign-off on the changes made.  I just wanted to make sure that
we get these changes in soon (with out delay).

I can wait if you want to keep ownership of the patch, I just wanted to
ensure that we get your patch included as soon as possible based on the
problem it fixes.

--=-cvNNgoliNaK4I4ddV4MT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3HqJAAoJEOVv75VaS+3OswsP/itC3rAYDIHiBiTohny7jF4L
tdi/T1mSxqrsr35NrXJQdAhYw2K3yLjwRqMnSteafvFfbr8bherWuYLWidO6Udp8
YDq0mN62RI9vGEjQ8nfvAkiGljWbzpiVd5WXAMZe4cSDwz9ogi8D+Or2alp4BJpf
yeLMWJshyafg0Z9GkcQM43fxyrb5vjLUZE3Fxf7iHGeFyMWlTmagMGOhO8d3Tvkr
XRPyDexDvCiqBIWNCGygkM0hipyg7p7Bs+/3N+fRqEJDMsoI1GyGxlk3m8t4/7iB
VLeah/R4MDjhrf9CmzY0/RWPRcceLkqlh45uKWH+zQ3O60pL5Z93/ki6+D2jz2/E
/IkoE8TeyaapJgUBO5ftqvd7XScQy/k1jmOXniVUx+hL1YZ/uPW4GsYw8nA/kW8l
OoGGgAhniJIVd2Y6bH/SaVdPLQiREn4D7XpI/dNpty1MoyLg/xB07eKuWintvpnB
MBJbBdFZ4wR7im9L7Kt34vJSti1zXiN7b+Pf8zyeLdKI/Vh9k8I1gDI8IuK58gSX
/CtGCuudPzQb1306l5A67LaMM8X1LgJ6Rc/UqvUgyLfjTayxUd6DKSG986KM1f7U
UROnKvO6NrPOnes7+i7VGB6OOjXAT7EFkugh1MmFXN+kG310Ys436AenF58j2MNB
BXxVzrfzcgUSiqjOJxN5
=Mmp6
-----END PGP SIGNATURE-----

--=-cvNNgoliNaK4I4ddV4MT--
