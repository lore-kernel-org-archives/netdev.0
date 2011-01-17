From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.9)
Date: Mon, 17 Jan 2011 18:54:11 +0100
Message-ID: <1295286851.3335.36.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
	 <1295077542.3977.20.camel@edumazet-laptop>
	 <20110117092532.7d5f5a5b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47848 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab1AQRyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 12:54:17 -0500
Received: by vws16 with SMTP id 16so2117080vws.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 09:54:16 -0800 (PST)
In-Reply-To: <20110117092532.7d5f5a5b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 09:25 -0800, Stephen Hemminger a =C3=A9=
crit :

> I rolled in your changes. But there is one more change I want to make=
=2E
> The existing flow match based on hash is vulnerable to side-channel D=
oS attack.
> It is possible for a hostile flow to send packets that match the same
> hash value which would effectively kill a targeted flow.
>=20
> The solution is to match based on full source and destination, not ha=
sh value.
> Still coding that up.

I see, but you only want to make this full test if (!q->filter_list)  ?

(or precisely only if skb_get_rxhash() was used to get the cookie )





