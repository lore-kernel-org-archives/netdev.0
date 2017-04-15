From: Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 1/4] dt-bindings: net: Add TI WiLink shared transport
 binding
Date: Sat, 15 Apr 2017 21:38:18 +0200
Message-ID: <20170415193817.r57lubkln72vvjcn@earth>
References: <20170413150353.7389-1-robh@kernel.org>
 <20170413150353.7389-2-robh@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="mcpuvkep2cnkpc7f"
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170413150353.7389-2-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--mcpuvkep2cnkpc7f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Apr 13, 2017 at 10:03:50AM -0500, Rob Herring wrote:
> Add serial slave device binding for the TI WiLink series of Bluetooth/FM/=
GPS
> devices.
>=20
> Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
> v3:
> - rebase on bluetooth-next
>=20
>  .../devicetree/bindings/net/ti,wilink-st.txt       | 35 ++++++++++++++++=
++++++
>  1 file changed, 35 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/ti,wilink-st.txt b/Doc=
umentation/devicetree/bindings/net/ti,wilink-st.txt
> new file mode 100644
> index 000000000000..cbad73a84ac4
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/ti,wilink-st.txt
> @@ -0,0 +1,35 @@
> +TI WiLink 7/8 (wl12xx/wl18xx) Shared Transport BT/FM/GPS devices
> +
> +TI WiLink devices have a UART interface for providing Bluetooth, FM radi=
o,
> +and GPS over what's called "shared transport". The shared transport is
> +standard BT HCI protocol with additional channels for the other function=
s.
> +
> +These devices also have a separate WiFi interface as described in
> +wireless/ti,wlcore.txt.
> +
> +This bindings follows the UART slave device binding in
> +../serial/slave-device.txt.
> +
> +Required properties:
> + - compatible: should be one of the following:
> +    "ti,wl1271-st"
> +    "ti,wl1273-st"
> +    "ti,wl1831-st"
> +    "ti,wl1835-st"
> +    "ti,wl1837-st"
> +
> +Optional properties:
> + - enable-gpios : GPIO signal controlling enabling of BT. Active high.
> + - vio-supply : Vio input supply (1.8V)
> + - vbat-supply : Vbat input supply (2.9-4.8V)
> +
> +Example:
> +
> +&serial0 {
> +	compatible =3D "ns16550a";
> +	...
> +	bluetooth {
> +		compatible =3D "ti,wl1835-st";
> +		enable-gpios =3D <&gpio1 7 GPIO_ACTIVE_HIGH>;
> +	};
> +};

Reviewed-by: Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

-- Sebastian

--mcpuvkep2cnkpc7f
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAljydqcACgkQ2O7X88g7
+poIAQ/+IVVT4w5FCkq5wlBYNb9AhYbE9+9Kt9o6RM+FMShesp5yOq61F5IfUTJJ
vSsnwFjnwnyc78KUw4Rp2Q1WjUvo71B5r3nM0NrFkp0HU+Idf+gQL3N8jieIUl4b
rSL1+lpEK5EsR7Uv8SS7huB5DnwGT1cL7goSF4l/TCPhiOEU6eJrSZrD8sYhtYGz
yXHpxjojKhJiLP8ZVCPnD7QBi/BjiExCsjIoWR45WBhxVpMVxWu0ZaK5p5S8sGLw
IrEjHgXwQ2PACbAAgsWQe1kOqD5/2mJ9a1PbhrIfCvcg89cMDwDb8Wojf+nnIAQ5
dWl7dqfMffCYEFjlWhSXXhEZ+MVJOzQwncU4R1ZNRFZiZ6MKcPJUrXxPgD+V58xo
5nsbp7u0BDu71/rJ3XAUX+M0ygMvy/7VJ8uXqYxKlPp5RyRCXxSV8Dgf1l2LDiMd
NBClFKwqvq+il7oB8sVK1/4Lpwxyf2+HF3mT8rrUAjsJ7mrXSeQtoqB7T6aiv7nT
L3jTzCyYHo6/NNVqk0ENaRh32Kv6JvNMN2GK1Jm9R9IHDw6gevSOo29xRIWTtoz+
n7hfeImJYSR/imFOJLdh87Gq/+OdtDkAKMUr5G07tYOtEHzm3YZnP1GrJPiC6LTJ
zSMcCuO2URcPTri25mmhgQMTh9GCAgd4ZOJ/+uv1Q/EA1Kd4IVo=
=y9TH
-----END PGP SIGNATURE-----

--mcpuvkep2cnkpc7f--
