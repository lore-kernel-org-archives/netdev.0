From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] ixgbevf: fix VF untagging when 802.1 prio is set
Date: Tue, 17 Jul 2012 19:31:31 -0700
Message-ID: <1342578691.2143.27.camel@jtkirshe-mobl>
References: <1342578236-20036-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cvJENdIxOufZnf7vbXec"
Cc: Pascal Bouchareine <pascal@gandi.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38514 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308Ab2GRCbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:31:33 -0400
In-Reply-To: <1342578236-20036-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cvJENdIxOufZnf7vbXec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-17 at 19:23 -0700, Jeff Kirsher wrote:
> From: Pascal Bouchareine <pascal@gandi.net>
>=20
> We have had an issue when using ixgbe+ixgbevf and 802.1 VLAN tagging.
>=20
> When attaching a VLAN to a VF, frames with a 802.1q priority appeared
> untagged on the VF hence not reaching the VLAN, where frames with
> priority 0 where tagged as expected and seen by the VLAN device.
>=20
> This seems due to the way ixgbevf is looking up the full tag
> (prio+cfi+vlan) against the adapter active_vlans, as a condition to
> mark
> the skb tagged.
>=20
> Signed-off-by: Pascal Bouchareine <pascal@gandi.net>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)=20

Dave-

Disregard, I just read your message about "that's it for net".  I will
push this into my net-next tree.

Cheers,
Jeff

--=-cvJENdIxOufZnf7vbXec
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQBiAEAAoJEOVv75VaS+3OHJYP/i79S7irF47sZEHzyy7fcmcl
k1gP8B1ZsIOQfsN8QV57oKnPCMjiv6tTRunFzDj3Ia75DlA18x9T7reCfyaEyrQj
f5LbQu2wl7S1Ac5Ol6oEuBsPjSamzD/DbSl9KhKRPaunj5VlgymEt0XfZ9hwvZYp
MUbw/cWDMQV2EaoDorjZNkXUbqBg/cDvfBee5rTkXigvCD0J471uKJDOYglyxlWd
HHHjeYR7584kWw75r0xKkMiFBMxPcJexh/4wVWWoaicGikvDKM2VbsFdEVZ4NdtN
1TSHyoBPfc6hUycO/t26cNnsdkL0IXoMnwQaNTupb692cRUhfifDDnRJolzeIfV5
m5y9EHIbnUgyTGV2hD18ECMo1FSszzSiw2VUk4BLcGuDfV7xj2QssWbpPEUB7i9O
d70LgAQuMX9MVG7s81jgU8BIBpjyj4qJsyrlcQZ/Ag8oKcLlOKSpgwPAzzUbt2Dp
zunF/rdOZBumC9XYR1bh9pv7yM1cSNw001xHDqrue6DKOrJslQoryCa3TysW8WfC
oFEsXuV+G8cX4lCpwFyK3fN4XwisTrZ4qc1hEZ/PYqqVhw2y8pAk4phd3WmyV3HU
ti0GRAI6h2sUn8YxnXHIQsbqSK9G6RDOMGlGlvJp82+ZAb8aYZILofNCmJlTx2Sb
++wwM/jHr0/+NeFGRF4l
=Xjy1
-----END PGP SIGNATURE-----

--=-cvJENdIxOufZnf7vbXec--
