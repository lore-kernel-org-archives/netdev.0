From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Re: [Prism54] CVS -> bk tree update
Date: Wed, 16 Jun 2004 01:11:03 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040616051103.GN6253@ruslug.rutgers.edu>
References: <20040614191651.GC6253@ruslug.rutgers.edu>
	<40CE2754.1020109@pobox.com>
	<20040616022008.GM6253@ruslug.rutgers.edu>
	<40CFBA24.7030307@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0244149481=="
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40CFBA24.7030307@pobox.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0244149481==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pY3vCvL1qV+PayAL"
Content-Disposition: inline


--pY3vCvL1qV+PayAL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 15, 2004 at 11:10:28PM -0400, Jeff Garzik wrote:
> Luis R. Rodriguez wrote:
> >Thanks Jeff. I did, and a diff of Andrew's -mm tree Vs our cvs tree
> >2.6.7-prism54 gives a 1898 line diff. This is excluding spaces,
> >newlines, and tabbing and all of Andew's .orig, .rej's.=20
> >
> >This time it's going to be a *real* pain to provide a changelog and spli=
t=20
> >the
> >diffs.. so can I just send you that 1898 line diff and then another for
> >space changes? Everything has already been reviewed on the lists here...
> >
> >I promise this will be our last big patch too. I'll ask our team
> >to send patches from now on to netdev after each ChangeLog entry, for
> >more public review and to not loose sync of our trees. Let us know if
> >you think we should do otherwise.
>=20
>=20
> Sorry, no.  You knew that split-up patches would be needed, once the=20
> initial driver merge is complete (which was complete before the most=20
> recent series of 17 patches).

Actually no. I wasn't aware of how netdev patches went upstream until
the driver got in and our first set of patches got rejected. After the
driver got in the kernel the first set of patches was just to get the
kernel tree up to speed with what *really* was current in our cvs tree
(remember Jean was the one who submitted the original patch).

What occurred afterwards was more of a misunderstanding of what is
acceptable and what is not for patches for network driver projects. I
thought, since you had suggested to continue with the prism54 project,
and submit a patch for our next release. No one on our dev team or=20
lists knew any better or didn't say much to make us think otherwise.

> This is one of the big downsides to developing in CVS,=20

<edit> for the kernel since what's mainly used by mantainers is
bitkeeper </edit>=20

> and it bites=20
> people again and again.

CVS is used as a project repository, not *the linux kernel repository*. It =
would
seem to me reasonable though that if a project is doing a good job in
making sure code gets tested, keeping a tight bugzilla, cvs daily
updates, a detailed changelog, and viewcvs, that a big patch sent out to
kernel mantainers for a new driver project release version would just be
accepted. Apparantly not and *this* is what sucks about using CVS -- the
fact these rules for small patches exist, and that the kernel uses a
different versioning system. And that's it.

> Linux kernel development relies on split-up patches for review, testing,=
=20
>  and narrowing down which patch in a series introduced a bug.  There=20
> are real, engineering-related reasons we do things this way.

Don't get me wrong... I love this. I think that because of this is why
we have such a great kernel. The problem here was that there was
miscommunication between you, Jean, and us. The patch shouldn't have
been accepted to include the driver into the kernel until=20
our main project goals were completed. We then did not know the details=20
on followup procedures to update netdev drivers, nor were we told.

We've learned our lesson the hard way. Oh well. Just please warn others
submitting new drivers too -- submit until you think you only have small
changes left, and also integrate the driver by verifying first with the=20
mantainers (warn about patch policy, etc).

We'll just send patches for *every* CVS changelog entry from now on.

This also just makes me want to just consider using bitkeeper. What benefit=
s are
there for our project, would we be able to get write access, and how
else would procedures change for us?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--pY3vCvL1qV+PayAL
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAz9Znat1JN+IKUl4RAuDLAJ0S0Lo2X6PxH3ipd0rdNlVmBHgUEQCcCfLr
RuT3vZNziF6YKeErzylw/HI=
=Ukft
-----END PGP SIGNATURE-----

--pY3vCvL1qV+PayAL--

--===============0244149481==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0244149481==--
