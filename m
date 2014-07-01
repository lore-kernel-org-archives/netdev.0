From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/3] can: m_can: add Bosch M_CAN controller support
Date: Tue, 01 Jul 2014 12:33:20 +0200
Message-ID: <53B28E70.6050406@pengutronix.de>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com> <1403863246-18822-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OdQgDA5Uelf9KSlxfhgcKKAa83hD8dEA1"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	devicetree@vger.kernel.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403863246-18822-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OdQgDA5Uelf9KSlxfhgcKKAa83hD8dEA1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/27/2014 12:00 PM, Dong Aisheng wrote:
> +static int m_can_close(struct net_device *dev)
> +{
> +	struct m_can_priv *priv =3D netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&priv->napi);
> +	m_can_stop(dev);
> +	free_irq(dev->irq, dev);
> +	close_candev(dev);
> +	can_led_event(dev, CAN_LED_EVENT_STOP);

You forgot to turn of the clock.

> +
> +	return 0;
> +}

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OdQgDA5Uelf9KSlxfhgcKKAa83hD8dEA1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOyjnAACgkQjTAFq1RaXHM/FgCeNMrFZT+urCgwKq6RyImIg0mj
v9gAnj966IDRQFHhPFUWaZ4tySI/WEAU
=OvOJ
-----END PGP SIGNATURE-----

--OdQgDA5Uelf9KSlxfhgcKKAa83hD8dEA1--
