From: Giel van Schijndel <me@mortis.eu>
Subject: Re: [PATCH RESEND 2/2] wlcore: align member-assigns in a
 structure-copy block
Date: Sun, 11 Jan 2015 21:32:01 +0100
Message-ID: <20150111203201.GG7918@salidar.dom.custoft.eu>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
 <1420659525-22975-1-git-send-email-me@mortis.eu>
 <1420659525-22975-2-git-send-email-me@mortis.eu>
 <87vbkfga32.fsf@kamboji.qca.qualcomm.com>
 <CAB3XZEcm4+=dYC-8_m_7YRdET_wPkWUYHcDuy9mCKdxkCFEnQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3xoW37o/FfUZJwQG"
Cc: Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Eliad Peller <eliad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB3XZEcm4+=dYC-8_m_7YRdET_wPkWUYHcDuy9mCKdxkCFEnQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3xoW37o/FfUZJwQG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 11, 2015 at 12:22:49 +0200, Eliad Peller wrote:
> On Fri, Jan 9, 2015 at 7:03 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Giel van Schijndel <me@mortis.eu> writes:
>>> This highlights the differences (e.g. the bug fixed in the previous
>>> commit).
>>>
>>> Signed-off-by: Giel van Schijndel <me@mortis.eu>
>>> ---
>>>  drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
>>>  1 file changed, 11 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireles=
s/ti/wlcore/acx.c
>>> index f28fa3b..93a2fa8 100644
>>> --- a/drivers/net/wireless/ti/wlcore/acx.c
>>> +++ b/drivers/net/wireless/ti/wlcore/acx.c
>>> @@ -1715,17 +1715,17 @@ int wl12xx_acx_config_hangover(struct wl1271 *w=
l)
>>>               goto out;
>>>       }
>>>
>>> -     acx->recover_time =3D cpu_to_le32(conf->recover_time);
>>> -     acx->hangover_period =3D conf->hangover_period;
>>> -     acx->dynamic_mode =3D conf->dynamic_mode;
>>> -     acx->early_termination_mode =3D conf->early_termination_mode;
>>> -     acx->max_period =3D conf->max_period;
>>> -     acx->min_period =3D conf->min_period;
>>> -     acx->increase_delta =3D conf->increase_delta;
>>> -     acx->decrease_delta =3D conf->decrease_delta;
>>> -     acx->quiet_time =3D conf->quiet_time;
>>> -     acx->increase_time =3D conf->increase_time;
>>> -     acx->window_size =3D conf->window_size;
>>> +     acx->recover_time               =3D cpu_to_le32(conf->recover_tim=
e);
>>> +     acx->hangover_period            =3D conf->hangover_period;
>>> +     acx->dynamic_mode               =3D conf->dynamic_mode;
>>> +     acx->early_termination_mode     =3D conf->early_termination_mode;
>>> +     acx->max_period                 =3D conf->max_period;
>>> +     acx->min_period                 =3D conf->min_period;
>>> +     acx->increase_delta             =3D conf->increase_delta;
>>> +     acx->decrease_delta             =3D conf->decrease_delta;
>>> +     acx->quiet_time                 =3D conf->quiet_time;
>>> +     acx->increase_time              =3D conf->increase_time;
>>> +     acx->window_size                =3D conf->window_size;
>>
>> I would like to get an ACK from one of the wlcore developers if I should
>> apply this (or not).
>>
> I don't have a strong opinion here.
> However, it looks pretty much redundant to take a random blob (which
> was just fixed by a correct patch) and re-indent it.
> The rest of the file doesn't follow this style, so i don't see a good
> reason to apply it here.
>=20
> I agree such indentation have some benefit, but it won't help with the
> more common use case (of copy-paste error) of copying the wrong field
> (i.e. D->a =3D S->b instead of D->a =3D S->a).
> For these cases the macros suggested by Arend and Johannes will do the
> trick. However i usually dislike such macros, as they tend to break
> some IDE features (e.g. auto completion).
> Maybe we can come up with some nice spatch to catch these cases.

What I dislike about those macros is just that they're not as familiar
to any C programmer as the assignment operator, so they make the code
less readable (even if just a little bit).

As for the IDE thing: I try not to use them, but have been told (by
colleagues) that Eclipse is reasonably smart about macros in C. I use
VIM with the clang_complete plugin and that does do proper completion
with expressions containing macros, but not inside macros based on what
the macro expansion would be, like the one above.

That's why I believe this kind of alignment is at least *an* improvement
even if it doesn't solve all possible problems.

--=20
Met vriendelijke groet,
With kind regards,
Giel van Schijndel
--
"Question: what do you call your programming methodology?
 Answer: Faith based development. You code and then pray that it works."
  -- John Spelner

--3xoW37o/FfUZJwQG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlSy3b8ACgkQZBYm/87l50LZ0ACeL4zkWdTsuJW99qgDOqA7qWZI
WPoAn1XzcExsiqdIkz+EufXyOeQdeZ13
=sz4K
-----END PGP SIGNATURE-----

--3xoW37o/FfUZJwQG--
