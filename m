From: Bernd Eckenfels <be-mail2007@lina.inka.de>
Subject: Re: Mcast packet loss 2.6.8.1 kernel
Date: Sat, 1 Dec 2007 19:53:18 +0100
Message-ID: <20071201185318.GA30674@lina.inka.de>
References: <1195112740.4853.14.camel@linux-ak10.SGC> <E1IswSr-0006Nd-00@calista.eckenfels.net> <20071116123822.39babae8.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071116123822.39babae8.dada1@cosmosbay.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2007 at 12:38:22PM +0100, Eric Dumazet wrote:
> Hello Bernd
>=20
> I did some investigations on the "netstat -s" problem and one
>  fix is to change the size of char buf1[1024], buf2[1024];

I changed it now to 2048, and included your page aligend io buffer patc=
h. It
is available in net-tools HEAD (net-tools.berlios.de)

It would be good if I can get a few tests on different architectures.

Gruss
Bernd
--=20
  (OO)     -- Bernd_Eckenfels@M=F6rscher_Strasse_8.76185Karlsruhe.de --
 ( .. )    ecki@{inka.de,linux.de,debian.org}  http://www.eckes.org/
  o--o   1024D/E383CD7E  eckes@IRCNet  v:+497211603874  f:+497211515161=
29
(O____O)  When cryptography is outlawed, bayl bhgynjf jvyy unir cevinpl=
!
