From: Raphael Hertzog <raphael@ouaza.com>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Wed, 17 Jun 2009 16:36:47 +0200
Message-ID: <20090617143647.GD18586@rivendell>
References: <20090615075313.GA22819@rivendell>
 <Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
 <20090615160254.GA8550@rivendell>
 <Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
 <20090617130050.GA18586@rivendell>
 <Pine.LNX.4.64.0906171659380.31880@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-15?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakeen.ouaza.com ([212.85.152.62]:48969 "EHLO
	arrakeen.ouaza.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbZFQOgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 10:36:48 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906171659380.31880@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 juin 2009, Ilpo J=E4rvinen a =E9crit :
> On Wed, 17 Jun 2009, Raphael Hertzog wrote:
>=20
> > Le lundi 15 juin 2009, Ilpo J=E4rvinen a =E9crit :
> > > Maybe the proxy interferes there somehow... I don't know enough a=
bout the
> > > details to say but I suppose the proxy at least breaks your tcp c=
onnection=20
> > > to two parts.
> >=20
> > Indeed. Is there some processing done in a simple linux bridge wher=
e the
> > reapperance of the same TCP packet that has been created and sent o=
n another
> > local interface could create problem?
>=20
> I thought out had a http proxy in between? I suppose it is certainly =
doing=20
> more than bridging. Anyway, I'll be week away, so no quick responses =
are=20
> to be expected from my part after this mail.

Well, I have the problem when I don't use the proxy... if I use it, the
download is split over two TCP connections and things are fine.

Hence my question was if something could be confused by the fact that t=
he
same packet is seen twice on the same machine once (in output) via eth2=
/xenbrD
and once (in forward) via xenbrE (the routing between both bridges is d=
one
by the domU independently of the dom0 network config).

Cheers,
--=20
Rapha=EBl Hertzog -+- http://www.ouaza.com

=46reexian : des d=E9veloppeurs Debian au service des entreprises
http://www.freexian.com
