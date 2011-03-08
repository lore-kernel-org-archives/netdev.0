From: Steffen Sledz <sledz@dresearch.de>
Subject: Re: [PATCH v3] tcp: ioctl type SIOCOUTQNSD returns amount of data
 not sent
Date: Tue, 08 Mar 2011 12:57:22 +0100
Message-ID: <4D7619A2.4090207@dresearch.de>
References: <20110304123950.2c91ebd9@lxorguk.ukuu.org.uk> <1299441595-18455-1-git-send-email-sledz@dresearch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mario Schuknecht <m.schuknecht@dresearch.de>
To: netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299441595-18455-1-git-send-email-sledz@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 06.03.2011 20:59, schrieb Steffen Sledz:
> From: Mario Schuknecht <m.schuknecht@dresearch.de>
>=20
> In contrast to SIOCOUTQ which returns the amount of data sent
> but not yet acknowledged plus data not yet sent this patch only
> returns the data not sent.
>=20
> For various methods of live streaming bitrate control it may
> be helpful to know how much data are in the tcp outqueue are
> not sent yet.
>=20
> Signed-off-by: Mario Schuknecht <m.schuknecht@dresearch.de>
> Signed-off-by: Steffen Sledz <sledz@dresearch.de>
> ---
>  include/linux/sockios.h |    4 +++-
>  net/ipv4/tcp.c          |    9 +++++++++
>  2 files changed, 12 insertions(+), 1 deletions(-)

This is the patch version modified according to the comments from Alan =
Cox.

Anything else to do?

Steffen

--=20
DResearch Fahrzeugelektronik GmbH
Otto-Schmirgal-Str. 3, 10319 Berlin, Germany
Tel: +49 30 515932-237 mailto:sledz@DResearch.de
=46ax: +49 30 515932-299
Gesch=E4ftsf=FChrer: Dr. Michael Weber, Werner M=F6gle;
Amtsgericht Berlin Charlottenburg; HRB 130120 B;
Ust.-IDNr. DE273952058
