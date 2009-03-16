From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] tcp: simplify tcp_current_mss
Date: Sun, 15 Mar 2009 20:10:53 -0700 (PDT)
Message-ID: <20090315.201053.220050794.davem@davemloft.net>
References: <12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, zbr@ioremap.net, mingo@elte.hu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbZCPDLH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:11:07 -0400
In-Reply-To: <12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 02:07:53 +0200

> There's very little need for most of the callsites to get
> tp->xmit_goal_size updated. That will cost us divide as is,
> so slice the function in two. Also, the only users of the
> tp->xmit_goal_size are directly behind tcp_current_mss(),
> so there's no need to store that variable into tcp_sock
> at all! The drop of xmit_goal_size currently leaves 16-bit
> hole and some reorganization would again be necessary to
> change that (but I'm aiming to fill that hole with u16
> xmit_goal_size_segs to cache the results of the remaining
> divide to get that tso on regression).
>=20
> Bring xmit_goal_size parts into tcp.c
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
