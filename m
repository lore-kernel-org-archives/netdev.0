From: =?iso-8859-1?q?francois=20donzet?= <fdonzet@yahoo.fr>
Subject: Re: problem in driver network code
Date: Mon, 10 Nov 2003 09:14:17 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110081417.55732.qmail@web25201.mail.ukl.yahoo.com>
References: <20031107181508.A1102@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031107181508.A1102@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 --- Rask Ingemann Lambertsen <rask@sygehus.dk> a
=E9crit=A0: > On Fri, Nov 07, 2003 at 09:38:44AM +0100,
francois
> donzet wrote:
> >=20
> > It seems to me that there is a problem ;). If i
> store
> > in skb->csum a sum of all words of the packet
> data, it
> >  will be unusable by tcp (the skb->csum doesn't
> > contain the checksum of tcpheader plus data only,
> as
> > the ipheader is part of the packet when the sum is
> > computed)
>=20
> That can be accounted for by the TCP code because
> the IP header is known to
> the TCP code. IIRC, the pseudoheader is similiar to
> a real IP header, so it
> may take just a few lines of code to make up for the
> difference, but I
> haven't checked that.

The theory seems fine, but there is no clue of this
way in the code.

> What do you do with an IEEE 802.1q (VLAN) or 802.2
> (LLC) packet? The VLAN
> code in vlan_skb_recv() does not adjust skb->csum or
> skb->ip_summed. Neither
> does the 802.2 code.

no matter the link layer header is 802.3,802.2 or
8021.q . Tcp checksum offloading is supported,
whatever the type of the link layer (as skb->csum is
computed without the link layer header).



___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
