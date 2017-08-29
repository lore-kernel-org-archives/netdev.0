From: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
Subject: Re: [PATCH 6/6] power: supply: make device_attribute const
Date: Tue, 29 Aug 2017 10:44:21 +0200
Message-ID: <20170829084421.4nm3uoswlx2ftc5m@earth>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
 <1503315792-14837-7-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="iboistu4ap57qf3f"
Cc: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        jbacik@fb.com, jikos@kernel.org, benjamin.tissoires@redhat.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br, dvhart@infradead.org,
        andy@infradead.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-pm@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:55829 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdH2Io0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 04:44:26 -0400
Content-Disposition: inline
In-Reply-To: <1503315792-14837-7-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iboistu4ap57qf3f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Aug 21, 2017 at 05:13:12PM +0530, Bhumika Goyal wrote:
> Make these const as they are only passed as an argument to the
> function device_create_file and device_remove_file and the corresponding
> arguments are of type const.
> Done using Coccinelle.
>=20
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---

Thanks, queued.

-- Sebastian

>  drivers/power/supply/olpc_battery.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/power/supply/olpc_battery.c b/drivers/power/supply/o=
lpc_battery.c
> index fc20ca3..3bc2eea 100644
> --- a/drivers/power/supply/olpc_battery.c
> +++ b/drivers/power/supply/olpc_battery.c
> @@ -559,7 +559,7 @@ static ssize_t olpc_bat_error_read(struct device *dev,
>  	return sprintf(buf, "%d\n", ec_byte);
>  }
> =20
> -static struct device_attribute olpc_bat_error =3D {
> +static const struct device_attribute olpc_bat_error =3D {
>  	.attr =3D {
>  		.name =3D "error",
>  		.mode =3D S_IRUGO,
> --=20
> 1.9.1
>=20

--iboistu4ap57qf3f
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlmlKWUACgkQ2O7X88g7
+pojrA//WxkyTMch/7SoNoIGVqwKBdT4Xv7H5s/rB2lDnXCBsBlvFDm2vskHQJjQ
RAoHXz6vAsaYLdbG5pcgvOy4sV4jir2syPPv+GNoXAIuBkP5cx1jXJ1ZN81pWB65
BDhCe9i27V+HUm7iNqbkXDxILcpPoQki+skr9EvDgku2sgb3XIi9/zK+Gr42THct
APqsXxFSjDckjlZGJoyb7uS9Uo3SfP58rNaCf5jMHZ1s5IWwuvb9rEb3v6wKAcT9
uN2/hWOr2EAvS7dCcSOMn/fpWUqx5sf2U+Gm3ki+wU71JpKEvUnpoWNiiOQ1HZ3m
u3plo2L107xl9JYlJvxMG8dri3nyFTf9hypAqa1vtKI0oRnS10o6CiKtXSzcDHaP
Yyto1hwy1+1gq9mUrcy3Y754/h/Rtblz3uN7Mnlg9ZHgAYm4sq+z36hVwCvDNRIi
QspbkoBT0sYILb00j2mqiWDT5iGfGUAN1ybexqE996M3g8Ghja8BioOjO23SoxD/
SZfWT/Mbz+fkF9ZgyH2dMEWXKPXZoUrhuZGEUzWBU8BPRCoTQEY/zIJyK+Ojguxj
54GGUP5qq4kmUPZTj2BDzq1F03IgoFnuA7w3TqcKME920VCB/sdnfBV4wXmE4ccB
TNpI7Ow0/V8ZPXcFxny2GdyBSDjDJbRTQ+3tsQDzhVzx3kzDs5k=
=hkX3
-----END PGP SIGNATURE-----

--iboistu4ap57qf3f--
