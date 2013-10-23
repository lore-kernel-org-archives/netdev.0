From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 03/16] batman-adv: add bat_orig_print API function
Date: Wed, 23 Oct 2013 19:18:10 +0200
Message-ID: <20131023171810.GB2651@neomailbox.net>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
 <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
 <1382547630.22433.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="0ntfKIWw70PvrIHh"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32822 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab3JWRS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 13:18:58 -0400
Content-Disposition: inline
In-Reply-To: <1382547630.22433.23.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0ntfKIWw70PvrIHh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 23, 2013 at 10:00:30AM -0700, Joe Perches wrote:
> On Wed, 2013-10-23 at 18:04 +0200, Antonio Quartulli wrote:
> > Each routing protocol has its own metric and private
> > variables, therefore it is useful to introduce a new API
> > for originator information printing.
> >=20
> > This API needs to be implemented by each protocol in order
> > to provide its specific originator table output.
> []
> > +static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
> > +				     struct seq_file *seq)
> []
> > +	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
> > +		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
> > +		   "Nexthop", "outgoingIF", "Potential nexthops");
>=20
> This header printf really doesn't add much with the formatting sizes.
> It's pretty obscure why some of these are sized and others not sized.
> For instance: %-15s doesn't refer to a mac address size.
> Perhaps it'd be better to just emit the fixed string just using
> BATADV_TO_MAX_VALUE.  It'd also be easier to find via grep.

This string is printed out of a debugfs file and follows a format that we h=
ave
been using for long time (this patch is just moving this code from one poin=
t to
another).

I didn't get what you mean with BATADV_TO_MAX_VALUE (maybe you meant
BATADV_TQ_MAX_VALUE? but even in this case I don't get it).

The sized parameters in the format string are such that this header is corr=
ectly
aligned with the entries of the table that follow.
Moreover we tried to keep this table human readable as much as possible.

Here you have an example of what we get (this output is not printed with ex=
actly
that format string because it belongs to an older batman-adv version)

[B.A.T.M.A.N. adv 2013.3.0, MainIF/MAC: mesh0/xx:xx:xx:xx:xx:xx (bat0)]
  Originator      last-seen (#/255)           Nexthop [outgoingIF]:   Poten=
tial nexthops ...
             yyyy    4.720s   (247)              yyyy [     mesh0]:        =
     aaaaa (221)            bbbbbb (200)
            aaaaa    4.270s   (237)             ddddd [     mesh0]:        =
      aaaa (195)            vvvvvv (215)
           bbbbbb    4.480s   (248)            cccccc [     mesh0]:        =
      bbbb (213)            cccccc (200)
            ccccc    0.480s   (255)             bbbbb [     mesh0]:        =
      cccc (217)            dddddd (190)
           dddddd    1.050s   (223)            dddddd [     mesh0]:        =
    dddddd (191)              eeee (203)

If the width of your terminal is adequate you get a nice table which is rat=
her
helpful for debugging purposes.


Regards,


--=20
Antonio Quartulli

--0ntfKIWw70PvrIHh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSaATSAAoJEADl0hg6qKeOWkcP/1YPR5tybnB+Wfwm7Do7s0aH
LBorzAH4oGtlPVF3D+qmPZVd39GdUu43ggNBGLTvmt6CGJ9lGJQeuY7i/QSfTdT8
DF5P5XCBTyLA6kCgMKiLMTKyHD1sbn4v+XrdctzJqIvvgpEDoNSKKULV6LQXkr5H
FeWr80QZny86m+qXvDQII9XbfGPTNC3Te14TcB+SsBOLgiR8Ovi+m+iS7JWRE9s2
2br1oY9Llfw7jVXcZe1w+Vg56YayyXp3giGnuGbx4oQy2vCiXMhaxo0YO773zxzU
OnVb/4csXi66dCP1wLt5Z5zK27PUCRzC1w0vplg8cn4Ob6Wo0/z6Xqwcq9SbUHto
58HDVPVyvsu8+/g4mfurzuDA0m1bFAZiiVFYFEO3BpaTJpE68vI33oCcUhhj5B0q
CEvPshdITNc4+D35g6XwJL0vrM3g05Yk9nybomHkFVdaYnSonu5hSbTei/XOnF18
pBdxEOLnhxvBUx6frnM25LIoI/OhQGOJ3ZmiFp5B3CnwUFLuNoIFEeY9YFX17Lls
ligs+Fhfz/0ANku0phuLU5JCaiRtKQPaucVx0A8yKfclu6zmqtrWGTMKz/3uABbw
7wIoupNbEuLswyJITojpzTo9EdqIae8TkZGOsA0NwX2hsiFQWsALZmEIEgHE2dNJ
idZSsvBXF3tEELQ+xLO8
=8M2Y
-----END PGP SIGNATURE-----

--0ntfKIWw70PvrIHh--
