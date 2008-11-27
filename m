From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 15/39] i2400m: host-to-device protocol definitions
Date: Thu, 27 Nov 2008 11:04:25 +0100
Message-ID: <1227780265.3809.55.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <b488d4082cea6779ade2b487efd0ce6a1ad9c343.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LVnfOcU5WLwyt2/Yk8mE"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59834 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbYK0KFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:05:10 -0500
In-Reply-To: <b488d4082cea6779ade2b487efd0ce6a1ad9c343.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LVnfOcU5WLwyt2/Yk8mE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> +/* Message types */
> +enum i2400m_mt {
> +	I2400M_MT_RESERVED              =3D 0x0000,
> +	I2400M_MT_INVALID               =3D 0xffff,
> +	I2400M_MT_REPORT_MASK		=3D 0x8000,
> +
> +	I2400M_MT_GET_SCAN_RESULT  	=3D 0x4202,
> +	I2400M_MT_SET_SCAN_PARAM   	=3D 0x4402,
> +	I2400M_MT_CMD_RF_CONTROL   	=3D 0x4602,
> +	I2400M_MT_CMD_SCAN         	=3D 0x4603,
> +	I2400M_MT_CMD_CONNECT      	=3D 0x4604,
> +	I2400M_MT_CMD_DISCONNECT   	=3D 0x4605,
> +	I2400M_MT_CMD_EXIT_IDLE   	=3D 0x4606,
> +	I2400M_MT_GET_LM_VERSION   	=3D 0x5201,
> +	I2400M_MT_GET_DEVICE_INFO  	=3D 0x5202,
> +	I2400M_MT_GET_LINK_STATUS  	=3D 0x5203,
> +	I2400M_MT_GET_STATISTICS   	=3D 0x5204,
> +	I2400M_MT_GET_STATE        	=3D 0x5205,
> +	I2400M_MT_GET_MEDIA_STATUS	=3D 0x5206,
> +	I2400M_MT_SET_INIT_CONFIG	=3D 0x5404,
> +	I2400M_MT_CMD_INIT	        =3D 0x5601,
> +	I2400M_MT_CMD_TERMINATE		=3D 0x5602,
> +	I2400M_MT_CMD_MODE_OF_OP	=3D 0x5603,
> +	I2400M_MT_CMD_RESET_DEVICE	=3D 0x5604,
> +	I2400M_MT_CMD_MONITOR_CONTROL   =3D 0x5605,
> +	I2400M_MT_CMD_ENTER_POWERSAVE   =3D 0x5606,
> +	I2400M_MT_GET_TLS_OPERATION_RESULT =3D 0x6201,
> +	I2400M_MT_SET_EAP_SUCCESS       =3D 0x6402,
> +	I2400M_MT_SET_EAP_FAIL          =3D 0x6403,
> +	I2400M_MT_SET_EAP_KEY          	=3D 0x6404,
> +	I2400M_MT_CMD_SEND_EAP_RESPONSE =3D 0x6602,
> +	I2400M_MT_REPORT_SCAN_RESULT    =3D 0xc002,
> +	I2400M_MT_REPORT_STATE		=3D 0xd002,
> +	I2400M_MT_REPORT_POWERSAVE_READY =3D 0xd005,
> +	I2400M_MT_REPORT_EAP_REQUEST    =3D 0xe002,
> +	I2400M_MT_REPORT_EAP_RESTART    =3D 0xe003,
> +	I2400M_MT_REPORT_ALT_ACCEPT    	=3D 0xe004,
> +	I2400M_MT_REPORT_KEY_REQUEST 	=3D 0xe005,



Since this is all device-specific, this is like implementing all of
802.11 management with iwpriv. Do you really want that? Why wouldn't
most of these commands port over to other hardware?

johannes

--=-LVnfOcU5WLwyt2/Yk8mE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLnClAAoJEKVg1VMiehFYDR4P/3v+aOvPVFFnM6s0GV8DcOdw
jqNOa0Y5I0nhEmZnCIg22nEs75/aE/FdBu4XRN53Cfb48N/0Npmycy9m2b1IA9l7
qDBASln3DzQkDbrHRxvwlV/RGGZMAB1WLpyMgYHL9PQeJkhyWDnoOldCfAb/6m03
V2HBcwPzjgA6K22cbXduAUi6w0t69B/Y/PgnvrhLfQDEsoV9k9cWOYSNn1XAcNzI
LNOH9rJ9KEoPdIgImuf8AFVCldHVP0Q0rZt5w73HfCPVnJfwxwGQrbqlochcI79T
1m4hGYe6bJZbhrm6td1UdntHbfrRCHoQeKeiqIDGF5PP00HOaIAADhk71+vpIsHb
TkT8j60MLOaNukzU4Ke6CRFykmTHA2Ydz8GRIclWL+CCVWTv7TKWynRWt5N/fS0A
3W+MML/t72ZRPUUwaReT4DPL9ZzXSPjlnsPEpz4Gq9Km0MIlkXRoMwcb2e1iziAA
SZq8bos5IwDOoH7WK2HRWJ3KlFDuLQ+/a4jN3BTXhvKlUg1URn+CvHSWjVtE0XH0
VXb6WjhwO/ntYbQexCVROMbFJyHX6uWDDToUMbr9280HyvkOs+zU51AjelzBEAPD
QuUdmtrEejblKTzxXkU+WPQD84JpHTu8YHC+ka5Abk3Tk4Mw4MXbhor72DFTT+Ls
OL813gUm3e272kNfTJPF
=zI4Q
-----END PGP SIGNATURE-----

--=-LVnfOcU5WLwyt2/Yk8mE--

