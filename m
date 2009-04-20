From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP: Peer messages
Date: Sun, 19 Apr 2009 20:11:00 -0700
Message-ID: <20090419201100.55bfb6bb@nehalam>
References: <20090418180303.18963ff0@nehalam>
	<Pine.LNX.4.64.0904191408090.21005@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46473 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbZDTDLI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 23:11:08 -0400
In-Reply-To: <Pine.LNX.4.64.0904191408090.21005@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 19 Apr 2009 14:19:36 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Sat, 18 Apr 2009, Stephen Hemminger wrote:
>=20
> > Running some log-term tests of (using bittorrent of latest Ubuntu r=
eleases).
> > I see no problems with firewall rules (or sky2 driver), but I do se=
veral=20
> > of these:=20
> >=20
> >=20
> > [28286.893945] TCP: Peer <ip scrubbed>:63659/51413 unexpectedly shr=
unk window 414881290:414894358 (repaired)
> > [47312.851937] TCP: Peer <ip scrubbed>:43793/51413 unexpectedly shr=
unk window 888816585:888823785 (repaired)
>=20
> This is what was earlier the Treason uncloacked message until somebod=
y=20
> was scared to death because of it and we had to change the wording.
>=20
> And it's what the old kernels do for us (and there are plenty of such=
=20
> kernels around), and possibly broken middleboxes too. Unless you have=
 a=20
> tcpdump of a specific case or can clearly say that its frequency is m=
uch=20
> larger than it used to be in some between kernel versions consistent =
test=20
> setup, I'm not going to waste my time on debugging obsolete remote en=
ds.
>=20
> But, now that I think it a bit more, we could possibly but a WARN_ON=20
> somewhere if we ever sent past advertized window to make a distinctio=
n=20
> between our and their bugs.
>=20

12 over 3 days is not enough to worry about.
