From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 22:37:28 +0100
Message-ID: <20091203223728.3d5efa74@houba>
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
	<20091203202328.62d7551a@houba>
	<alpine.DEB.2.00.0912032207430.776@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:46288 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753573AbZLCVhq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:37:46 -0500
In-Reply-To: <alpine.DEB.2.00.0912032207430.776@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Thu, 3 Dec 2009 22:36:53 +0200 (EET),
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
> however, annoying thing is that now we didn't get get the zero events
> logged :-). Can you please print them also in that branch. Also, I
> forgot previously that tp->frto_counter would be nice to know. And
> since there seems to be a need for yet another case, in order to
> solve the other problem related to fast retransmit, also tp->lost_out
> and tp->sacked_out would be nice to know.

=2E12 is online, including patch

I added the fields and moved the printk at the beginning of
retransmits_timed_out as sk is not modified in the function.

I'm preparing one test without the "|| !tp->retrans_stamp"

--=20
=46r=C3=A9d=C3=A9ric Leroy
