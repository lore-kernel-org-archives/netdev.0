From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Fri, 23 Nov 2012 09:48:22 +0100
Message-ID: <50AF3856.8060808@pengutronix.de>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <1353481873-3214-1-git-send-email-olivier@sobrie.be> <20121122150149.GB11612@hposo> <20121122213022.GB1461@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCA05F932244CC87D5405C74B"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Daniel Berglund <db@kvaser.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39444 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758127Ab2KWIs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 03:48:27 -0500
In-Reply-To: <20121122213022.GB1461@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCA05F932244CC87D5405C74B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/22/2012 10:30 PM, Greg KH wrote:
> On Thu, Nov 22, 2012 at 04:01:49PM +0100, Olivier Sobrie wrote:
>> Hi linux-usb folks,
>>
>> Is there someone who can help me to fix the following errors?
>>
>> smatch warnings:
>>
>> + drivers/net/can/usb/kvaser_usb.c:431 kvaser_usb_send_simple_msg() er=
ror: doing
>> +dma on the stack ((null))
>> + drivers/net/can/usb/kvaser_usb.c:1073 kvaser_usb_set_opt_mode() erro=
r: doing
>> +dma on the stack ((null))
>> + drivers/net/can/usb/kvaser_usb.c:1174 kvaser_usb_flush_queue() error=
: doing
>> +dma on the stack ((null))
>> + drivers/net/can/usb/kvaser_usb.c:1384 kvaser_usb_set_bittiming() err=
or: doing
>> +dma on the stack ((null))
>>
>> I assume it's due to the buffer I pass to the function usb_bulk_msg()
>> which is on the stack and can't be.
>> Do I just have to kmalloc a buffer and give it to the usb_bulk_msg()
>> function? That's what I understood by reading
>> "Documentation/DMA-API-HOWTO.txt" section "What memory is DMA'able?"..=
=2E
>> and from commit
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dcom=
mitdiff;h=3D32ec4576c3fb37316b1d11a04b220527822f3f0d
>=20
> Yes, that is all that is needed.

Thanks Greg. Olivier, you can post an incremental patch, I'll squash it
before sending the patches upstream.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigCA05F932244CC87D5405C74B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCvOFYACgkQjTAFq1RaXHP8zgCfXL7QwPfE6fiKNdiQ5ZeXsVOf
808AoJF1LciKcviKKekSaOln4cmaM5/2
=H3j0
-----END PGP SIGNATURE-----

--------------enigCA05F932244CC87D5405C74B--
