From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Where Linux 802.11x support needs work
Date: Thu, 27 Jan 2005 11:24:13 -0500
Message-ID: <200501271124.19740.flamingice@sourmilk.net>
References: <20050126024039.GA25326@bougret.hpl.hp.com> <200501252341.27041.flamingice@sourmilk.net> <41F74757.3090104@tihlde.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5833706.pRRU4JzTVu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <41F74757.3090104@tihlde.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart5833706.pRRU4JzTVu
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 26 January 2005 2:31 am, Roar Bj=F8rgum Rotvik wrote:
> Michael Wu wrote:
> > On Tuesday 25 January 2005 11:03 pm, Dan Williams wrote:
> >>> One of the big item not mentionned by you is the in-kernel
> >>>802.11 stack (native frames and management). If done right, I guess it
> >>>would mostly be transparent to you...
> >>
> >>You know, I was thinking of it and I just forgot to put it on the list.
> >>If you're including madwifi and ipw2x00, we have a grand total of what,=
 3
> >>or 4 802.11 stacks in the kernel at the same time?  (madwifi,
> >>orinoco/hermes, ipw2x00, linux-wlan-ng)
> >
> > Only orinoco/hermes is in the kernel, and that doesn't really have much
> > of an 802.11 stack, since most things are done in hardware. Madwifi has=
 a
> > fairly complete 802.11 stack (ported from netbsd), and so does adm8211.
> > Dunno about ipw2x00.
>
> Do any of these 80.11 stacks (or the upstream linux network stack) have
> a solution for WLAN cards with 802.11e (QoS extension) with more than
> one HW/firmware transmit queues?
>
I'm not aware of any. The latest revision of the adm8211 chip supports more=
=20
than one tx queue, but only one is used.

=2DMichael Wu

--nextPart5833706.pRRU4JzTVu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB+RWzyWWBbDEe0UIRAsvQAKC2Hohfpza8M4mWicwC+l0LuuBQMACcCPe2
qDh28cG5ClFTufEqSurfcAY=
=zs4Z
-----END PGP SIGNATURE-----

--nextPart5833706.pRRU4JzTVu--
