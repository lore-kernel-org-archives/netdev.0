From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: skb_shift cannot cache frag ptrs past
 pskb_expand_head
Date: Tue, 25 Nov 2008 13:57:30 -0800 (PST)
Message-ID: <20081125.135730.24376719.davem@davemloft.net>
References: <Pine.LNX.4.64.0811252202550.14851@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57982
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752487AbYKYV5a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 16:57:30 -0500
In-Reply-To: <Pine.LNX.4.64.0811252202550.14851@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 25 Nov 2008 22:08:06 +0200 (EET)

> Since pskb_expand_head creates copy of the shared area we
> cannot keep any frag ptr past de-cloning. This fixes the
> tcpdump recvfrom -EFAULT problem.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Good catch.

I think everyone mucking around with these sorts of things
has made this error at least once or twice :)
