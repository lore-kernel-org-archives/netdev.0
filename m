From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: generic 802.11 stack
Date: Wed, 15 Sep 2004 08:44:38 +0300
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <200409150844.45242.vkondra@mail.ru>
References: <4145352F.4040807@pobox.com> <20040915030545.GA25307@havoc.gtf.org> <20040915031732.GL7839@ruslug.rutgers.edu>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1219258.HLbHKuVhPC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net,
 "David S. Miller" <davem@davemloft.net>,
 greg chesson <greg@atheros.com>,
 hadi@cyberus.ca,
 Jeff Garzik <jgarzik@pobox.com>,
 "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
 netdev@oss.sgi.com,
 prism54-devel@prism54.org,
 sam@errno.com
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20040915031732.GL7839@ruslug.rutgers.edu>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--nextPart1219258.HLbHKuVhPC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Let me answer to the set of questions raised:

=2D dual licensing: I am not ready to answer for legal. I will discuss with=
=20
proper people and answer.

=2D code style: regardless of answer on question above, I intend to do Linu=
x=20
work and will not care about compatibility macros. I really dislike such=20
macros, they do make code hard to understand.

=2D information sharing (driver-stack): good question indeed. I am currentl=
y=20
evaluating it. This far, I think I will supply some standard link layer=20
information per packet. Like rate, RSSI etc. For Tx, it will include also=20
crypto key for hardware assisted encryption, type of protection (RTS/CTS=20
etc.) I believe it should be sufficient. To prove it, I am going to write=20
some dummy .11 driver that will be capable to simulate any Rx, with user=20
interface for feeding packets. I will use this driver to debug stack.

It is complex issue to support all combination of job separation between ho=
st=20
and NIC, I will choose some model like "NIC do almost nothing" and will=20
develop around it.=20

Vladimir.

On Wednesday 15 September 2004 06:17, Luis R. Rodriguez wrote:
LR> On Tue, Sep 14, 2004 at 11:05:45PM -0400, Jeff Garzik wrote:
LR> > On Tue, Sep 14, 2004 at 11:02:11PM -0400, Luis R. Rodriguez wrote:
LR> > > I proposed dual licensing not to specifically allow clear
 compatibility LR> > > among linux and the BSDs on the 802.11 work, but to
 allow BSDers to do LR> > > whatever they want with what we come up with --
 help with code sharing. LR> >
LR> >
LR> > Overall, He Who Writes The Code Gets To Choose.
LR> >
LR> > My own personal opinion is that the BSD license goes against the stat=
ed
LR> > spirit of Linux -- contribute back.  But that's just me.
LR> >
LR>
LR> Agreed -- but in this case I feel we're the bigger crowd so I wanted to
LR> address to the *author* that I feel we should be considerate to the BSD
LR> crowd.
LR>
LR>  Luis
LR>

--nextPart1219258.HLbHKuVhPC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBR9bNqxdj7mhC6o0RAvicAJ9S+JJLxreQBdV87DQMWt71ACAhvwCfbUFD
LbN2BOegk6f+D3w49PoRJ20=
=UuPp
-----END PGP SIGNATURE-----

--nextPart1219258.HLbHKuVhPC--


-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
