From: Kevin Dwyer <kevin@pheared.net>
Subject: Re: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Tue, 7 Oct 2003 17:08:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007170823.41ef2ff9.kevin@pheared.net>
References: <20031005130154.5bd9d182.kevin@pheared.net>
	<3F81F1CD.8050803@Carter.net>
	<20031006210600.37da62c9.kevin@pheared.net>
	<3F83276D.3070700@cs.uiuc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Tue__7_Oct_2003_17_08_23_-0400_oFn8zMF28kT3g8jy"
Cc: Casey Carter <Casey@Carter.net>, netdev@oss.sgi.com,
        linux-ha@lists.linux-ha.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Casey Carter <ccarter@cs.uiuc.edu>
In-Reply-To: <3F83276D.3070700@cs.uiuc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Signature=_Tue__7_Oct_2003_17_08_23_-0400_oFn8zMF28kT3g8jy
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Tue, 07 Oct 2003 15:51:57 -0500
Casey Carter <ccarter@cs.uiuc.edu> wrote:

> IMHO, the delivery should weigh sk_bound_dev_if much more strongly (7
> instead of 2), so that if-bound sockets are always favored over
> non-if-bound.  I would be happy to submit the (trivial) patch to do so
> if the networking gurus agree?

Any possibility of getting this behavior into 2.4 as well?  Albeit,
without the scoring since that's obviously a new concept introduced by
2.6. (Which I prefer; well done.)

I confess that I don't know who to talk to about such a change.

-- 
- kpd
"If at first you don't succeed, redefine success." - Anonymous

--Signature=_Tue__7_Oct_2003_17_08_23_-0400_oFn8zMF28kT3g8jy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/gytHN4rbBhHCVDkRAo6BAJ0RHd8TaDctV+UZxdG0hjamdFLcFACfbtte
8tsq4QQLj8PpGSOmciRBHsU=
=EgKz
-----END PGP SIGNATURE-----

--Signature=_Tue__7_Oct_2003_17_08_23_-0400_oFn8zMF28kT3g8jy--
