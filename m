From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Sun, 6 Dec 2009 21:32:29 +0100
Message-ID: <20091206213229.3966c1a5@houba>
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
	<4B1ADF79.6000101@tvk.rwth-aachen.de>
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
Received: from sd-11162.dedibox.fr ([88.191.70.230]:39546 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757884AbZLFUcs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 15:32:48 -0500
In-Reply-To: <4B1ADF79.6000101@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Sat, 05 Dec 2009 23:32:25 +0100,
Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :
>
> Could you please make another test and unplug the cable or drop ACKs
> for several seconds, so that some RTO retransmissions are performed?
> I'd like to see if retrans_stamp remains constant. In the dmesg
> output of the 11th run, it seems to change while icsk_retransmits
> also increases. This is kind of bad for connection timeout
> calculation in the RTO case ...

=2E17 is online :)
I disconnected physically the stream 2 times. The first was maybe too
short and recover immediatly. The second disconnect is longer and
took several second to recover.
I hope this help !

--=20
=46r=C3=A9d=C3=A9ric Leroy
