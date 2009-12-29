From: Valdis.Kletnieks@vt.edu
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 16:46:22 -0500
Message-ID: <17290.1262123182@localhost>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org> <20091229151146.GA32153@us.ibm.com> <3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com> <20091229163939.GA6984@us.ibm.com> <3e8340490912290901y60d7daf2w5778c25f44972955@mail.gmail.com> <m1fx6ty6ds.fsf@fess.ebiederm.org> <3e8340490912291108t7e000e75p8264fa585f831464@mail.gmail.com>
            <20091229212722.GA20178@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1262123182_4680P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Bryan Donlan <bdonlan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@zeniv.linux.org.uk>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 29 Dec 2009 15:27:22 CST."
             <20091229212722.GA20178@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1262123182_4680P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, 29 Dec 2009 15:27:22 CST, =22Serge E. Hallyn=22 said:
> I think i disagree.  A uid is just a uid (or should be).  One day we ma=
y
> have a way for a factotum-style daemon to grant the ability to an unpri=
v
> task to setuid without CAP_SETUID.  I think slingling uids and gids
> around that you already have access to should be fine.

Yes, but not doing the clear and obvious simple thing now for a =22one da=
y
we may have=22 consideration seems a poor engineering tradeoff.

Yes, slinging uids and gids around *would* be nice.  But first we need a =
clear
plan for making /usr/bin/newgrp a shell builtin - once that happens, *the=
n*
we can re-address this code. ;)

--==_Exmh_1262123182_4680P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLOniucC3lWbTT17ARAs0iAKDROPsJGHgiRPPfWpj6729MmCkN9ACdH//t
XuiooxKyTetj7/KjkjrPQsI=
=vzQ/
-----END PGP SIGNATURE-----

--==_Exmh_1262123182_4680P--

