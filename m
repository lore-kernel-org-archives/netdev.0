From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Sat, 10 Jan 2015 09:37:13 -0800
Message-ID: <1420911433.5947.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54AEA498.5030202@uclouvain.be>
	 <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
	 <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=dhW=0hRYHjjgBh0KwKOQfzHhwY2egusQ8S4tsoJb0Nsg@mail.gmail.com>
	 <54B11255.7000500@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:58054 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbbAJRhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 12:37:17 -0500
Received: by mail-qc0-f170.google.com with SMTP id x3so13334075qcv.1
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 09:37:16 -0800 (PST)
In-Reply-To: <54B11255.7000500@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-01-10 at 12:51 +0100, S=C3=A9bastien Barr=C3=A9 wrote:

> That looks much more readable compared to my v2.
> It is currently passing our tests (These are in fact MPTCP tests appa=
rt=20
> from Neal's packetdrill that I will add, but actually the MPTCP stack=
=20
> happens to reveal this situation quite easily, I think because in MPT=
CP,=20
> we store the send queue in the "meta-flow", which currently cannot be=
=20
> used for tail loss probes).
>=20
> As probably everyone will be happy with this (Eric as well ?), I sugg=
est=20
> I prepare a v3 once all our tests are passed as well, with Yuchung's=20
> structure and Neal's packetdrill test in the commit text. Will also a=
dd=20
> proper credit as there is now stuff from several people in those few=20
> lines now :-).
>=20
> Looks good ?

Definitely !

Thanks !
