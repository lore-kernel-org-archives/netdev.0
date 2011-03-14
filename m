From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: bug fix in transmission headers
 with frags=0
Date: Mon, 14 Mar 2011 15:35:50 +0100
Message-ID: <1300113350.3423.32.camel@edumazet-laptop>
References: <4D7E167E.2090807@gmail.com>
	 <1300110977.3423.16.camel@edumazet-laptop>  <4D7E22A5.1000708@gmail.com>
	 <1300112338.3423.27.camel@edumazet-laptop>  <4D7E26A4.2070802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>,
	Jens Laas <jens.laas@its.uu.se>,
	Voravit Tanyingyong <voravit@kth.se>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57818 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755229Ab1CNOf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:35:56 -0400
Received: by fxm17 with SMTP id 17so2953494fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 07:35:55 -0700 (PDT)
In-Reply-To: <4D7E26A4.2070802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 15:31 +0100, Daniel Turull a =C3=A9crit :
> (bug introduced by commit 26ad787962ef84677a48c560
> (pktgen: speedup fragmented skbs)
>=20
> The headers of pktgen were incorrectly added in a pktgen packet
> without frags (frags=3D0). There was an offset in the pktgen headers.
>=20
> The cause was in reusing the pgh variable as a return variable in skb=
_put
> when adding the payload to the skb.
>=20
> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


