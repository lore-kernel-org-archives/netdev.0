From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Mon, 12 Feb 2007 07:28:23 +0100
Message-ID: <20070212062823.GB4756@melchior.yamamaya.is-a-geek.org>
References: <45C6BCE5.90103@shaw.ca> <20070204213603.a5bce839.akpm@linux-foundation.org> <45C6C531.20508@shaw.ca> <20070204221741.63152cbe.akpm@linux-foundation.org> <523e55a00702081326j43de05e3hdd8cf35e946eae9@mail.gmail.com> <45CBE30D.5030006@nvidia.com> <20070209115821.GD10330@melchior.yamamaya.is-a-geek.org> <20070209120730.GA11911@melchior.yamamaya.is-a-geek.org> <45CC8A2D.20509@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	David Ford <firefighterblu3@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robert Hancock <hancockr@shaw.ca>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:4849 "EHLO yumi.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933030AbXBLG22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 01:28:28 -0500
Content-Disposition: inline
In-Reply-To: <45CC8A2D.20509@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Tobias Diedrich wrote:
> >Tobias Diedrich wrote:
> >>Ayaz Abdulla wrote:
> >>>For all those who are having issues, please try out the attached p=
atch.
> >>Will try.
> >
> >Does not apply cleanly against 2.6.20, is this one fixed up right?
>=20
> It probably needs to be top of 2.6.20-git-latest or 2.6.20-rc6-mm3.
>=20
> IOW, the forcedeth changes in question are not in 2.6.20, and you nee=
d=20
> to apply the patch on top of the latest batch of forcedeth changes.

Well, it hasn't blown up on me despite being applied to 2.6.20...
The problem I was seeing might even be fixed in 2.6.20 vanilla,
since the last version I saw it in was 2.6.20-rc6 and then I
reverted to 2.6.19 to make sure that one is ok (see
20070130183208.GE11814@melchior.yamamaya.is-a-geek.org).

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
