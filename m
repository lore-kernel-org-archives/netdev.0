From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH RFC 0/2] e1000e: 82574 also needs ASPM L1
 completely disabled
Date: Mon, 23 Apr 2012 16:11:19 -0700
Message-ID: <20120423161119.0000022f@unknown>
References: <9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
	<1335216578-21542-1-git-send-email-bootc@bootc.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7656188826715140935=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	nix@esperi.org.uk, linux-kernel@vger.kernel.org
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-1-git-send-email-bootc@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============7656188826715140935==
Content-Type: multipart/signed; micalg=PGP-SHA256;
	boundary="Sig_/_GqVr+9M/caExEfma/f495s";
	protocol="application/pgp-signature"

--Sig_/_GqVr+9M/caExEfma/f495s
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Apr 2012 22:29:36 +0100
Chris Boot <bootc@bootc.net> wrote:
> Please note I haven't as-yet tested this code at all, but I do know that
> disabling ASPM L1 on these NICs (using setpci) fixes the hangs that I
> have been seeing on my Supermicro servers with X9SCL-F boards. I hope to
> get the chance to install an updated kernel on my two afftected servers
> later this week.
>=20
> Chris Boot (2):
>   e1000e: Disable ASPM L1 on 82574
>   e1000e: Remove special case for 82573/82574 ASPM L1 disablement

Thanks Chris, we are going to take a look over the patches and Jeff
Kirsher should apply them to our internal testing tree.

Please let us know the results of your testing, we will let you know if
we see any issues as well.

Jesse

--Sig_/_GqVr+9M/caExEfma/f495s
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQIbBAEBCAAGBQJPleGgAAoJEFi+OMPmMDUeSNUP+Ii9bDfh3tR9tSrzW18siof+
hhzeqsMCieSXFUdEEVYJBb/R9EHFVU/KJ09Nw/mNgU7F1hQOcvfxxFkgJrKzWCes
9eqKHksn5x3xxDO5vVd799i+yc01RU7pb5D+IXYH2S+kWkGYuQs6NDOj513gtZso
ablX5SPE/WvpxXlRwQa6l8eQskwZO0l9bNjD7KirawPj4+DAt96QWrTY+wyiJmG1
XySJxWor9zQiCq02sEjBRh6tTX1kHsGT439yKXzqDyDND8BWmlBD0M6W0jpFwcWL
UhvYSV6XVgR7KQdlfMkWKW1uRvwMQtMBmWnXP2fUMkNiOYb49VbnXf087pl2Z+vK
qcubjq6S65tYZSgOUJ0drTn7h5L1nlp016r0pzHQWlh6+hhySkLcrjU27a7DTckx
1odkZMSkzttABmFJXvoQ+Eji8KIuu4tM/zxAEOnZqysFqWqc12FPs6J0XHxcnrNo
pxts3+xDR/ZPGJw6lQCKQiRYiDCWgApFGBgF+OW7KN+QMB1CDBAs9IGE0CJjTqD1
8ZUc4myGBFDinQ8nzIy1rS2YSMw97fNtpzv/6ziwMAA/7URxpOjvAmT4oMzsVEJj
/UP/GdpvjakdcZ5DBhQYEvoa58eShuNEdft5SobKIc2RdqONuPb6/QwmirAVNwMy
LW8wLAIlpaATr91vAo8=
=TiZl
-----END PGP SIGNATURE-----

--Sig_/_GqVr+9M/caExEfma/f495s--


--===============7656188826715140935==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2

--===============7656188826715140935==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7656188826715140935==--
