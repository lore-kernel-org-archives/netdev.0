From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 20:23:28 +0100
Message-ID: <20091203202328.62d7551a@houba>
References: <20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
	<20091201211945.505d3c98@houba>
	<alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
	<20091202085925.472136e2@houba>
	<alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
	<20091202154403.GB30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
	<20091202183451.173db5f2@houba>
	<4B16BD58.3040802@tvk.rwth-aachen.de>
	<20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
	<4B17A791.80808@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
	<4B17C6C3.1060000@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:34453 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756559AbZLCTXq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 14:23:46 -0500
In-Reply-To: <4B17C6C3.1060000@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thu, 03 Dec 2009 15:10:11 +0100,
Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :
> > I suppose adding || !tp->retrans_stamp into the false condition is
> > fine as long as we don't then have a connection that can cause a
> > connection to hang there forever for some reason (this needs to be
> > understood well enough, not just test driven in stables :-)).
> >=20
> >> Unluckily, I still cannot reproduce the scp stalls here, so it
> >> would be nice if Frederic printed retrans_stamp together with
> >> icsk_ca_state and icsk_retransmits, please.
> >=20
> > It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
> > that might have some significant w.r.t what happens because of FRTO=
=2E
>=20
> I made a patch for Frederic with Codebase
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>=20
> Thanks for testing.

I made a new .11 trace with damian patch.
The copy went to the end.=20

http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.pca=
p.bz2
http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.dme=
sg.bz2
http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.pro=
c_net_netstat-before.bz2
http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.pro=
c_net_netstat-after.bz2
http://www.starox.org/pub/scp_stall/scp_stall-houba.11-patch_damian.sys=
ctl_net.ipv4.tcp-before.bz2

--=20
=46r=C3=A9d=C3=A9ric Leroy
