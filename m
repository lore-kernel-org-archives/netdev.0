From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Adding to linux-next?
Date: Tue, 6 Oct 2009 22:57:51 +1100
Message-ID: <20091006225751.7d5f3eec.sfr@canb.auug.org.au>
References: <4AC6339B.7000905@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__6_Oct_2009_22_57_51_+1100_DgyK78EqzKux/Yqu"
Cc: linux-next@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932252AbZJFL6j@vger.kernel.org>
In-Reply-To: <4AC6339B.7000905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__6_Oct_2009_22_57_51_+1100_DgyK78EqzKux/Yqu
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Sorry for the slow response.

On Fri, 02 Oct 2009 13:08:43 -0400 Gregory Haskins <gregory.haskins@gmail.c=
om> wrote:
>
> I am looking for some guidance on policy/procedure governing inclusion
> of a tree to linux-next.  For instance: Do I have to be arbitrarily
> invited (e.g. by some committee on LKML), or do I explicitly request
> consideration?  I tried to Google around for answers, and also found the
> linux-next wiki, but I was not getting any clear answers.

You just send me the location of your tree and ask for inclusion. You
should also mention who should be contacted if I have any problems with
this tree (I will assume yourself).

> I have these guest drivers to support IO on top of the AlacrityVM
> hypervisor:
>=20
> http://lkml.org/lkml/2009/8/3/278
>=20
> The comments have since died down.  I realize this can mean anything
> from "no objection" to "no interest" ;), but I assume the former unless
> someone pipes up.
>=20
> I believe I addressed the review comments and received an Ack from the
> one maintainer of the tree that overlaps with the work (netdev/davem), he=
re:
>=20
> http://lkml.org/lkml/2009/8/3/505
>=20
> Since the rest of the work doesn't really fall into any existing
> subsystem, and David conceded that the netdev overlap portion should
> carry elsewhere, I offer to fill this role myself from within the
> AlacrityVM tree itself.
>=20
> As such, I have taken the driver series and created a new branch here:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2=
.6.git
> linux-next

I will add this tree from tomorrow unless someone screams.

> Unlike the original posting, I have excluded the final ethernet patch
> since I posted a v3 today (http://lkml.org/lkml/2009/10/2/239) that I
> would like to have David re-Ack before including.
>=20
> Once the driver has been suitably approved by David, and if he still
> feels its ok to carry in a tree other than netdev, I will re-add it to
> the linux-next branch.

That sounds fine.

> Because I am not really sure of the policies for linux-next, let me
> state my intentions of this branch, since I am an unknown in the
> maintainership role:
>=20
> I will only post patches to this branch that:
>=20
> *) do not fall into an existing maintained subsystem category, unless
> the appropriate maintainer has relinquished the patch to carry in my tree.
> *) have previously been posted to LKML for suitable review.

Here is my boilerplate:

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Tue__6_Oct_2009_22_57_51_+1100_DgyK78EqzKux/Yqu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkrLML8ACgkQjjKRsyhoI8zt+ACeM+k6rqfDWmLJotjLpM0/WL0N
/4wAnjMwhjNvRkn1OueOkkFtRo+hb0FP
=tgtM
-----END PGP SIGNATURE-----

--Signature=_Tue__6_Oct_2009_22_57_51_+1100_DgyK78EqzKux/Yqu--
