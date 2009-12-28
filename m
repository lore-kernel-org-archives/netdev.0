From: Valdis.Kletnieks@vt.edu
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 09:37:24 -0500
Message-ID: <8817.1262011044@localhost>
References: <20091227190802.GH11737@elf.ucw.cz> <20091228060759.GB13266@heat>
            <20091228101006.GA19984@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1262011044_3923P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: Your message of "Mon, 28 Dec 2009 11:10:06 +0100."
             <20091228101006.GA19984@elf.ucw.cz>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1262011044_3923P
Content-Type: text/plain; charset=us-ascii

On Mon, 28 Dec 2009 11:10:06 +0100, Pavel Machek said:

> a) make disablenetwork reset to "enablenetwork" during setuid exec

That won't work either.  If you only make it 'setuid==0' binaries, you still
break 'setuid-FOO' binaries that require the net. If you just check the setuid
bit, it allows a trivial escape by creating a setuid-yourself binary and using
that to exec something else (now with network access, because we apparently
don't have a way to remember the previous setting).

> b) disallow setuid execs for tasks that have network disabled.

This is probably safer...


--==_Exmh_1262011044_3923P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLOMKkcC3lWbTT17ARAuXQAKDKSD04p/kzwOlcGrzMWIaZi0zdewCfYouK
fKvx9SgRred/XVHfSlWkL2U=
=oN+p
-----END PGP SIGNATURE-----

--==_Exmh_1262011044_3923P--

