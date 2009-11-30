From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 19:50:04 +0100
Message-ID: <20091130195004.38dbc319@houba>
References: <20091127223545.2a752429@houba>
 <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
 <20091128010156.1219012a@houba>
 <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:34026 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbZK3SuV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 13:50:21 -0500
In-Reply-To: <alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Sat, 28 Nov 2009 13:31:14 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> I restored Ccs. Please keep them.

Sorry,=20

> On Sat, 28 Nov 2009, Frederic Leroy wrote:
>=20
> > Le Sat, 28 Nov 2009 00:12:23 +0200 (EET),
> > "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
> >=20
> > > On Fri, 27 Nov 2009, Frederic Leroy wrote:
> > >=20
> > > > I put traces of stall here :=20
> > > > http://www.starox.org/pub/scp_stall/
> [...]
> Perhaps having the /proc/net/tcp would at least tell what state the
> timer is (if I cannot reproduce right away). ...It is rather strange
> that two independent mechanisms for loss recovery seem both to fail
> to get triggered here, no traces of retransmission whatsoever. I
> think it is for now enough to concentrate on what happens on
> 192.168.1.15 (=3Dhouba?) and get tcpdump and proc/net/tcp from there,
> the other end/direction has very little significance here (except for
> the fact that bidirectionality might be needed to actually trigger
> it). You could even think of getting proc/net/tcp a bit more often,
> right from the start:
>=20
> while [ : ]; do grep ":0016" /proc/net/tcp; sleep 0.1; done | tee
> scp_stall-houba.x.proc_net_tcp
>=20
> ...Please wait at least 2 minutes before hitting ctrl-c or otherwise=20
> artificially intervening.

You're right, 192.168.1.15 is houba.
The faulty behaviour comes back today, I did new captures on
192.168.1.15 only :=20
http://www.starox.org/pub/scp_stall/scp_stall-houba.2.pcap
http://www.starox.org/pub/scp_stall/scp_stall-houba.2.proc_net_tcp
http://www.starox.org/pub/scp_stall/scp_stall-houba.3.pcap
http://www.starox.org/pub/scp_stall/scp_stall-houba.3.proc_net_tcp

Which tool do you use to analyze /proc/net/tcp ?

--=20
=46r=C3=A9d=C3=A9ric Leroy
