From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 15:32:15 -0800
Message-ID: <47436E7F.2060901@redhat.com>
References: <20071119191000.GA1560@elf.ucw.cz>	<200711192304.25087.rjw@sisk.pl>	<4743026B.2020907@openvz.org>	<m11wakshyz.fsf@ebiederm.dsl.xmission.com>	<20071120215914.GE24156@elte.hu>	<m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>	<20071120223559.GA6655@elte.hu>	<20071120225457.B6E2D26F8BE@magilla.localdomain>	<20071120230106.GD24380@elte.hu>	<3d8471ca0711201506t6b2b88a0h9484f8a40a1f2e40@mail.gmail.com> <20071120232600.F1D2F26F8BE@magilla.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guillaume Chazarain <guichaz@yahoo.fr>,
	Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbXKTXgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 18:36:12 -0500
In-Reply-To: <20071120232600.F1D2F26F8BE@magilla.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Roland McGrath wrote:
> Oh, it seems it has indeed been that way for a very long time, so I w=
as
> mistaken.  It still seems a little odd to me.  Ulrich can say definit=
ively
> whether the kind of concern I mentioned really matters one way or the=
 other
> for glibc.

glibc cannot survive (at least NPTL) if somebody uses funny CLONE_*
flags to separate various pieces of information, e.g., file descriptors=
=2E
 So, all the information in each thread's /proc/self should be identica=
l.

When the information is not the same, the current semantics seems to be
more useful.  So I guess, no change is the way to go here.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFHQ25/2ijCOnn/RHQRAmhhAJsHRF7FqO8DWwZ97gHxIO/i4Z1AAQCffCGa
Q2J8kjthKbbNQf1USWMAw3Y=3D
=3Dxl/a
-----END PGP SIGNATURE-----
