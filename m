From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Mon, 30 Nov 2009 23:19:39 +0100
Message-ID: <20091130231939.715491b4@houba>
References: <20091127223545.2a752429@houba>
	<alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
	<20091128010156.1219012a@houba>
	<alpine.DEB.2.00.0911281257270.25587@melkinpaasi.cs.helsinki.fi>
	<20091130195004.38dbc319@houba>
	<alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi>
	<20091130213727.2f4047d2@houba>
	<alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:48404 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbZK3WTz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:19:55 -0500
In-Reply-To: <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 30 Nov 2009 23:37:56 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> Ok. Just wanted to confirm since it can be that that not all packets
> are in the tcpdump that TCP was sending. For what reason is unknown
> at the moment. Any fancy firewall (iptables) rules on houba that
> could do such a trick here?

Nothing with netfilter or schedulers on houba, neither on sg ( no log
because no iproute installed ...)
http://www.starox.org/pub/scp_stall/houba.netfilter.log

> Also, have you changed sysctl settings from the defaults?

No but I could have change defaults in the linux config file.

I saved the current content of /proc/sys/net and proc/net :=20
http://www.starox.org/pub/scp_stall/sg-proc_net-proc_sys_net.tbz2
http://www.starox.org/pub/scp_stall/houba-proc_net-proc_sys_net.tbz2

I put also linux config files in the directory.

> Could you try btw to disable frto (set tcp_frto sysctl to zero), in
> theory it could cause zero cwnd if something else is wrong too (I
> haven't yet read them all through so there might be other places
> where a zero cwnd can be set). Also I'm interested what happens if
> you disable timestamps, is the problem still reproducable.
=20
Ok, I'll try these tomorrow when it will fault again :)

--=20
=46r=C3=A9d=C3=A9ric Leroy
