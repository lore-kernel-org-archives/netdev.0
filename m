From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Sun, 13 Jan 2008 23:51:13 -0800 (PST)
Message-ID: <20080113.235113.170762359.davem@davemloft.net>
References: <Pine.LNX.4.64.0801121420220.19333@kivilampi-30.cs.helsinki.fi>
	<20080112.202414.192104180.davem@davemloft.net>
	<Pine.LNX.4.64.0801140920580.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbYANHvR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 02:51:17 -0500
In-Reply-To: <Pine.LNX.4.64.0801140920580.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 14 Jan 2008 09:43:08 +0200 (EET)

> So which test case you prefer? :-) Is iso-8859-1 from+content ok? Or=20
> should I keep trying to live with mixed utf-8 which I didn't got even=
=20
> fully working last time because git-send-email is probably either too=
 dumb=20
> or too intelligent (I'm not even sure which), but you were able corre=
ct it=20
> by your tools so the flawed signed-off never entered to the git logs =
as=20
> incorrectly formatted :-).
>=20
> I'd prefer sending them as iso-8859-1 compliant (and I guess you are =
able=20
> to test your fix-to-utf-8 machinery with it as well :-)), as it would=
 also=20
> make my mails compatible with other people's git apply tools you're n=
ot=20
> using (otherwise I'd probably forget to change it occassionally when=20
> interacting with others than you).

=46or now either way is fine with me.  If the situation changes I'll
let you know.

I'm surprised git-send-email can't get it purely utf8 correctly.

I wonder if there is some issue with how it gets your name
string for the commit author etc.

I wonder if getting it into your global GIT config file in proper
UTF8 encoding would fix things.

Put something like this into ~/.gitconfig

--------------------
[user]
	name =3D Ilpo J=E4rvinen
	email =3D ilpo.jarvinen@helsinki.fi
--------------------

The GIT maintainer is Finnish which makes this situation even
more perplexing to me, you might want to discuss it with him :-)
