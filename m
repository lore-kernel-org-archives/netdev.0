From: Horms <horms@debian.org>
Subject: Bug#337089: linux-image-2.6.14-1-powerpc: add CONFIG_TCP_CONG_BIC=y
Date: Fri, 4 Nov 2005 12:27:27 +0900
Message-ID: <20051104032726.GD4708@verge.net.au>
References: <20051102162451.0002CF64E@ibook.free.fr>
Reply-To: Horms <horms@debian.org>, 337089@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.337089.B337089.113107853927270@bugs.debian.org>
To: =?UTF-8?Q?Beno=C3=AEt?= Dejean <benoit@placenet.org>,
	337089@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <20051102162451.0002CF64E@ibook.free.fr>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2005 at 05:24:50PM +0100, Beno=EEt Dejean wrote:
> Package: linux-image-2.6.14-1-powerpc
> Version: 2.6.14-1
> Severity: normal
>=20
> Hi,
> Linux < 2.6.14 used to have every TCP congestion algorithms as builtins=
 but
> NewReno + BIC was default.
>=20
> Linux 2.6.14 has splitted these features into modules. But default rema=
ins
> NewReno + BIC accordint to CONFIG_TCP_CONG_ADVANCED help message :
>=20
> "Nearly all users can safely say no here, and a safe default selection =
will
> be made (BIC-TCP with new Reno as a fallback)."
>=20
> And indeed NewReno+BIC is a good and safe default. Much better than New=
Reno
>=20
> But Debian .config has CONFIG_TCP_CONG_BIC=3Dm (CONFIG_TCP_CONG_*=3Dm) =
which
> makes NewReno default. So this is like a "regression". I'd like debian =
kernel
> to have CONFIG_TCP_CONG_BIC=3Dy provided that one can easily switch to =
another
> algorithm (using /proc/sys/net/ipv4/tcp_congestion_control).

Hi Netdev,

could someone please comment on what a good default congestion
algorithm setup for distribution kernels is?

Thanks

--=20
Horms
