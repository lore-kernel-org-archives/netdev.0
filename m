From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 05/10] ixgbe: never generate both software and
 hardware timestamps
Date: Fri, 14 Mar 2014 16:17:49 -0700
Message-ID: <1394839069.2167.91.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-6-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZJxmvcl2dp3GYq8KVwOv"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28815 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451AbaCNXRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:17:50 -0400
In-Reply-To: <1394818481-7652-6-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZJxmvcl2dp3GYq8KVwOv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> skb_tx_timestamp() does not report software time stamp
> if SKBTX_IN_PROGRESS is set. According to timestamping.txt
> software time stamps are a fallback and should not be
> generated if hardware time stamp is provided.
>=20
> Move call to skb_tx_timestamp() after setting
> SKBTX_IN_PROGRESS.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Jakub, I will add this patch to my queue.

--=-ZJxmvcl2dp3GYq8KVwOv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI44dAAoJEOVv75VaS+3OHWQP/3nLrELf3/zvKzH9PVhZu1af
dU6q+WbJuelF6RjSO6ujXOjsNd45JWU7QSgTvFwRfbCtP30F5wwnc2oSkVGGjRNq
6TnwDczjLFFb5TjudZLR7XkTpsk7kwonyK/SFLRfwQLNaL4rNx6JHP5xtVEQLQl+
me+X5Wx9sKxkCXC96ZDjjosFx7/uyQOdpre3EX+PNa2OqqQ+RCff1Y7HHqS29dX7
jGzQVArNefEFAdiiWOWWfbmkzXIA5x804hOv3vZuhXQhJ/YE3ZmmtuBWwNQh277N
mHqXlzuu3BTjj8nMGC6oUZGTQ4KudBughjqt6QS/f9aZErsPbCvnijqj0Dur1Z6N
zftyySfvYE1gJ+0cwKSWEOHmlN8K/vOVikNq3HTZmP13Xv5FMqPf7FHnOvIrREfe
fssKYCinhg9kBVnOsYleUtgwftnAOFP7uqPpLrJmaLT1VI0TwLazKtAkG4u/1jdB
72F/gtTxU4MAVeO9a+myZtZMpETgUaAqObfiXYBtqgu2OvLlmJzgt0WUh7ToowxY
CI74dwNdCLq717bo/jL4UoZMpZBVGwA8b+slv3VdY0T46B2HG7noq+guolYMHdmc
P5CoWCH0CWGBoPYRoyXatvvZytbLPg+7JXVY74E/4UhfYe4wVh+GO7TwL/eI+qOG
s1/okctWX4h1MI/UQtC/
=UJej
-----END PGP SIGNATURE-----

--=-ZJxmvcl2dp3GYq8KVwOv--
