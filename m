From: Valdis.Kletnieks@vt.edu
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 16:24:49 -0500
Message-ID: <14145.1262035489@localhost>
References: <20091228163108.GC13266@heat>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1262035489_4431P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org,
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
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:44423 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbZL1V1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 16:27:11 -0500
In-Reply-To: Your message of "Mon, 28 Dec 2009 11:31:09 EST."
             <20091228163108.GC13266@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1262035489_4431P
Content-Type: text/plain; charset=us-ascii

On Mon, 28 Dec 2009 11:31:09 EST, Michael Stone said:

> > Actually it does. Policy may well be "If the network works, noone can
> > log in locally, because administration is normally done over
> > network. If the network fails, larger set of people is allowed in,
> > because something clearly went wrong and we want anyone going around
> > to fix it."
> 
> Have you actually seen this security policy in real life? I ask because it
> seems quite far-fetched to me. Networks are just too easy to attack. Seems to
> me, from this casual description, that you're just asking to be ARP- or
> DNS-poisoned and rooted with this one.

Actually, I've seen a *lot* of similar "if things fail, more people can login
to fix it" policies.  For instance, a default Fedora box will require a root
password to login - but if you can't get to multi-user because the box is
scrozzled and boot into single user, no root password is required.

So if you're using Fedora and LDAP authentication, and reboot to single-user
to fix an LDAP issue, you do in fact have that policy in real life...

(And before you start shouting "but that's a stupid config to make root login
depend on LDAP", note that for many Microsoft Active Directory shops, they add
machines with Administrator rights for an Active Directory group, and then
disable local Administrator, which is exactly the same thing...  Stupid or
not, it's a *very* common policy.)


--==_Exmh_1262035489_4431P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLOSIhcC3lWbTT17ARAgF0AJoDigVJ9mt3CDqRFsu0uX9a8tpYewCeNvKT
5W8Pmh/BccabcO7s/2p9ymk=
=xP2S
-----END PGP SIGNATURE-----

--==_Exmh_1262035489_4431P--

