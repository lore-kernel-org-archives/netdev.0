From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 17:03:00 +0000
Message-ID: <20151126170300.GH1929@sirena.org.uk>
References: <E1a1sVV-00079q-My@optimist>
 <20151126121551.GE1929@sirena.org.uk>
 <87y4dllysz.fsf@kamboji.qca.qualcomm.com>
 <20151126132228.GG1929@sirena.org.uk>
 <87lh9kn1dz.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gHypzss5dW8YUwgb"
Cc: linaro-kernel@lists.linaro.org,
	kernel-build-reports@lists.linaro.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath10k@lists.infradead.org,
	linux-next@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87lh9kn1dz.fsf@kamboji.qca.qualcomm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gHypzss5dW8YUwgb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 26, 2015 at 06:58:32PM +0200, Kalle Valo wrote:
> Mark Brown <broonie@kernel.org> writes:

> > No, I didn't make much effort to check though since the use of ifdef was
> > clearly a bug waiting to happen anyway, I was more surprised it worked
> > at all than anything.

> Michal Marek explains[1] that this is due to commit cf4f21938e13
> ("kbuild: Allow to specify composite modules with modname-m") and has
> nothing to do with the wireless drivers reorganisation. I'll drop this
> patch as Michal will apply his fix to the kbuild tree.

It still ought to be fixed regardless of why it showed up - the
intention of the code is that we build the real thermal code regardless
of if that's modular or not but that's not what the code actually does.

--gHypzss5dW8YUwgb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWVztDAAoJECTWi3JdVIfQZfsH/j5BbsMESTHNsKSVftN52wLV
vBY9RxwUHln8MsEthVU2r1xiA+WjUiR59q0WeunUZI6pbEo8Ykydh4L5vbKpAbRv
REqb5kK4CJeP5UvddEkeGR9SPuBubrFcEE6gQxJtQKBCcdAgHzOY+YvqMF5GYHZL
/RE8NIZI8WeMQho5KCLGXLw00LhSQ1aPitlkVhuHiPle5cFbit4jSdbrR5r35DL8
E7OedYiZ3TNEfSSP3/Wk73TUTHNhKk9Jg3/uYB+T/A80waZx/ZC0DLxW8Fiv0C4I
63MyInN5NxLIcztHhzXAyJCcQxj2YYFElWzZLp99hnAwQIU3wtHS2wBNPGeUUKs=
=p6C8
-----END PGP SIGNATURE-----

--gHypzss5dW8YUwgb--
