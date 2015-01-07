From: Giel van Schijndel <me@mortis.eu>
Subject: Re: [PATCH 2/2] Fix copy-paste bug: assign from src struct not dest
Date: Wed, 7 Jan 2015 20:18:36 +0100
Message-ID: <20150107191836.GA18978@salidar.dom.custoft.eu>
References: <CAHp75Vetc+fgv=YrqPuW9YChez82h7N7VeX_5bW5tpXm2j=h7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: linux-kernel@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHp75Vetc+fgv=YrqPuW9YChez82h7N7VeX_5bW5tpXm2j=h7g@mail.gmail.com>
 <1420451671.9459.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 05, 2015 at 10:54:31 +0100, Johannes Berg wrote:
> On Sun, 2015-01-04 at 19:00 +0100, Giel van Schijndel wrote:
>> ---
>>  drivers/net/wireless/ti/wlcore/acx.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless=
/ti/wlcore/acx.c
>> index beb354c..93a2fa8 100644
>> --- a/drivers/net/wireless/ti/wlcore/acx.c
>> +++ b/drivers/net/wireless/ti/wlcore/acx.c
>> @@ -1725,7 +1725,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
>>  	acx->decrease_delta             =3D conf->decrease_delta;
>>  	acx->quiet_time                 =3D conf->quiet_time;
>>  	acx->increase_time              =3D conf->increase_time;
>> -	acx->window_size                =3D acx->window_size;
>> +	acx->window_size                =3D conf->window_size;
>=20
> It would be far better to fix the bug *first*, that way the bugfix can
> be cherry-picked/applied to trees that don't have the alignment.

I agree on the ordering.

As for:
> (And anyway I question the value of the alignment - if you really want
> to make this bug disappear you could perhaps use a macro)

And:
On Wed, Jan 07, 2015 at 20:40:57 +0200, Andy Shevchenko wrote:
> On Sun, Jan 4, 2015 at 8:00 PM, Giel van Schijndel <me@mortis.eu> wrote:
> > This highlights the differences (errors).
>=20
> Seems like patch for the patch. Just fix an error like it's done here:
> http://www.spinics.net/lists/linux-wireless/msg131667.html

IMO the aligned block of code has the significant advantage of taking
advantage of humans' ability to spot things that break a pattern. Which
in this case becomes *very* visible when properly aligned, because
without the alignment there is no (visual) pattern (or at least not one
very suitable for my "visual processing system", I know the same applies
to at least some others).

--=20
Met vriendelijke groet,
With kind regards,
Giel van Schijndel

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlSthooACgkQZBYm/87l50JySgCfQiL/iT3PzgOr3YqVE/ItFijE
zlQAnibAUYKjA8xW2iN1tla/QuqWiGZW
=6l9e
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
