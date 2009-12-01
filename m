From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Tue, 1 Dec 2009 21:19:45 +0100
Message-ID: <20091201211945.505d3c98@houba>
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
Received: from sd-11162.dedibox.fr ([88.191.70.230]:36248 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbZLAUUC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 15:20:02 -0500
In-Reply-To: <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 30 Nov 2009 23:37:56 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :

> On Mon, 30 Nov 2009, Frederic Leroy wrote:
>
> Could you try btw to disable frto (set tcp_frto sysctl to zero), in
> theory it could cause zero cwnd if something else is wrong too (I
> haven't yet read them all through so there might be other places
> where a zero cwnd can be set). Also I'm interested what happens if
> you disable timestamps, is the problem still reproducable.

I made 3 new traces and put it in the usual place.
One with frto set to 0, one just after with frto set to 2.

And the last with timestamp disabled.=20

All stream has stalled.

--=20
=46r=C3=A9d=C3=A9ric Leroy
