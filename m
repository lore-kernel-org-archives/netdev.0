From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 00/18] Make the big kernel lock optional
Date: Wed, 15 Sep 2010 19:37:18 +1000
Message-ID: <20100915193718.3117b7bb.sfr@canb.auug.org.au>
References: <1284492909-7147-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0826911471332585572=="
Cc: Matt, linux-sh@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>,
	linux-pci@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>,
	Picco <bob.picco@hp.com>, Jaroslav Kysela <perex@perex.cz>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	linux-s390@vger.kernel.org, Jesper Nilsson <jesper.nilsson@axis.com>,
	Mark Gross <mark.gross@intel.com>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Uytterhoeven <geert@linux-m68k.org>, Karsten, Geert,
	Ingo Molnar <mingo@elte.hu>, linux-media@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net,
	Clemens Ladisch <clemens@ladisch.de>, Jeff Dike <jdike@addtoit.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Mikael Starvik <starvik@axis.com>, Tejun Heo <tj@kernel.org>,
	linux-m68k@lists.linux-m68k.org,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Jesse Barnes <jbarnes@vi
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <user-mode-linux-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1284492909-7147-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=user-mode-linux-devel>
List-Post: <mailto:user-mode-linux-devel@lists.sourceforge.net>
List-Help: <mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: user-mode-linux-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============0826911471332585572==
Content-Type: multipart/signed; protocol="application/pgp-signature";
	micalg="PGP-SHA1";
	boundary="Signature=_Wed__15_Sep_2010_19_37_18_+1000_W4OgHxa=ez9J+hdT"

--Signature=_Wed__15_Sep_2010_19_37_18_+1000_W4OgHxa=ez9J+hdT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Sep 2010 21:34:51 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
>
> Stephen, please add
> git+ssh://master.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git config

Added from today.

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

--Signature=_Wed__15_Sep_2010_19_37_18_+1000_W4OgHxa=ez9J+hdT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMkJPOAAoJEDMEi1NhKgbsHl8H+gIjNh21BvYQwVmcAhiVTAfw
A05Ptgdei0a7COpn+ogKi9Hlt0eM1b31ewZ3pAmqwXiOogNuomSetuZlKWo523vH
4Ur59ge1eFX4U6dEebVnJXTBOUUZHa6/mdIp684Jc0Oeh4aQzEv4YQYrCeBVZfcW
Dr969+hoer3dWHJ3X7VELBeKt+y+k4g6YUIYwGTXKn77iV/GG72XdIV5N+AMiiT4
BZp+1LnGgW/tkBQOujbXbyh9/08fWN3J75blTap0LripOHuo03zhWCWR+EeEiMza
92dkYYVlSY/gjksREqeBZSrZk4RDM4emcm0FndfC3835suxcoGwZa6EaCqQrnXA=
=cKMf
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Sep_2010_19_37_18_+1000_W4OgHxa=ez9J+hdT--


--===============0826911471332585572==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
--===============0826911471332585572==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
User-mode-linux-devel mailing list
User-mode-linux-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel

--===============0826911471332585572==--
