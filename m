From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 18:16:24 +0100
Message-ID: <1290186984.3034.187.camel@edumazet-laptop>
References: <1290165472.3034.109.camel@edumazet-laptop>
	 <20101119.082125.193710226.davem@davemloft.net>
	 <1290185759.3034.179.camel@edumazet-laptop>
	 <20101119.090516.104057453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, netdev@vger.kernel.org, xiaosuo@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36580 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814Ab0KSRQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 12:16:29 -0500
Received: by wwa36 with SMTP id 36so4864541wwa.1
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 09:16:28 -0800 (PST)
In-Reply-To: <20101119.090516.104057453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 09:05 -0800, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 19 Nov 2010 17:55:59 +0100
>=20
> > Unfortunatly on x86_32 it also chose that f_k was more valuable in =
a cpu
> > register and accumulator A lost its register to get a stack slot
> > instead.
>=20
> Ok that tradeoff is terrible, but it depends upon knowledge we haven'=
t
> given to the compiler (yet).
>=20
> Let me think about this a bit...

By the way, I tried the 'register' keyword, and I knew it was a stupid
idea before even trying, since compiler ignored me : "What the hell do
you think you can tell me how to optimize this code ?"

(I am quite sure my laptop even smiled and sent to his neighbours a
broadcast saying "Hey buddies, this dumb guy tried the register C
keyword, isnt it funny ?")

Oh well...


