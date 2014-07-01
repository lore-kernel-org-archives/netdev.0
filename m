From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: do a reset on SR-IOV re-init if device is
 down
Date: Tue, 01 Jul 2014 04:54:39 -0700
Message-ID: <1404215679.2311.92.camel@jtkirshe-mobl>
References: <1404215149-20634-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Z5uKa9hlLtIBrENNlF/Z"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net, carolyn.wyborny@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9462 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbaGALzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:55:03 -0400
In-Reply-To: <1404215149-20634-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Z5uKa9hlLtIBrENNlF/Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-07-01 at 13:45 +0200, Stefan Assmann wrote:
> To properly re-initialize SR-IOV it is necessary to reset the device
> even if it is already down. Not doing this may result in tx unit
> hangs.
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
>  1 file changed, 2 insertions(+)

Thanks Stefan, I have added your patch to my queue.

--=-Z5uKa9hlLtIBrENNlF/Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJTsqF/AAoJEOVv75VaS+3OOM4P/RenYyjcbdBSUEHmqwxbbPdi
JMjfdw5+t4vK2fbZJXnnxUNQYXGn7M1ZCFlsO239HQGZvH8x7B92byZyRouHg7kr
bQZZ5CRtWSupVp2EbsVMu4pXLIwopcKBImv5zS+LydtGs4BwiBU31wMSawv3zSKd
w91vepdYMUEoRv+p2/nJTKWXaRL1BOBL1dTuUXjLUMD7hpEiJbX+D6yo8S+/jZys
z9YIPafk7kAvvag3ncfyriHcfIJD4gsPevAq8DucPDYWc/+JldHID5uwARyl5Tnt
7iFMve6fPJfsyDvaJ2KPP6mveeWp1wGomdbPaUJIShxQKPbwfrxsqB+KdzucN0Zu
hqnpNEaD85fjtWUsUMCHoMCHIkVl0jLPlckW4verXOozx2LS4WSzKqdSnTXTvdwX
a6xZyuBKPVNdd9wSTQXaRBa0DoOdmTgEbbrqds+akUPoPoFi+RduDfBxwIYq0/3j
eR0HElQxE6XwTcvKZI+qgtmJTA8Z5jZTS1lngfFZpX5iPU2W5RmhBITcqJr3ZzWS
wf2hJ1YDX+O2wNPR+33HDLTmRKs9HWwv8N4Nc+68qJPbSkzIz/aSUFOcjRr8kZDY
+iyH57cIgeWPuA+b/KIt2fpoILYe/qYOLT/q8h/sZ1T6QC+H19rhYZJJD+sTlgsJ
mfI0Bxljwr51z5ScIGkL
=Pbrl
-----END PGP SIGNATURE-----

--=-Z5uKa9hlLtIBrENNlF/Z--
