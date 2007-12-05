From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [TCP]: NAGLE_PUSH seems to be a wrong way around
Date: Wed, 05 Dec 2007 03:33:48 -0800 (PST)
Message-ID: <20071205.033348.155990962.davem@davemloft.net>
References: <1196786930388-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20071205.022634.114614917.davem@davemloft.net>
	<Pine.LNX.4.64.0712051242310.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36091
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750892AbXLELdt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 06:33:49 -0500
In-Reply-To: <Pine.LNX.4.64.0712051242310.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 5 Dec 2007 13:18:14 +0200 (EET)

> ...If I understood the very old history correctly, this bug was intro=
duced=20
> in 2.4.0-test12 which inverted !tail incorrectly to nonagle=3D=3D1.
>=20
> You can check include/net/tcp.h diffs from this commit:
> http://www.linux-mips.org/git?p=3Dlinux.git;a=3Dcommitdiff;h=3Dc9c061=
67e7933d93a6e396174c68abf242294abb
>=20
> ...Though it's very large one. So I included only the relevant portio=
n=20
> here below.

Thanks for the info, indeed it seems it has been broken this
way all this time.
