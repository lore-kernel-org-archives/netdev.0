From: Florian Fainelli <florian.fainelli@int-evry.fr>
Subject: Re: Network activity LED trigger
Date: Fri, 2 Mar 2007 15:16:06 +0100
Message-ID: <200703021516.06638.florian.fainelli@int-evry.fr>
References: <200703012241.49165.florian.fainelli@int-evry.fr> <200703021358.52224.florian.fainelli@int-evry.fr> <1172844668.4864.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:41675 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992471AbXCBOQ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 09:16:57 -0500
In-Reply-To: <1172844668.4864.46.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Le vendredi 2 mars 2007, jamal a =E9crit=A0:
> Where are these LEDs typically located? Are you talking about LEDs on=
 a
> network card for example? can you light them up in different colors?

Those LEDS are typically controlled by GPIO lines visible in front of t=
he=20
device. It is mostly targeted to embedded devices for which you do not=20
necessarily want to assign a LED to a given network interface

>
> cheers,
> jamal
>
> On Fri, 2007-02-03 at 13:58 +0100, Florian Fainelli wrote:
> > Hi All,
> >
> > Some more thoughts. The IDE activity LED trigger is currently trigg=
ered
> > when a function is called in the IDE writing/reading routines.
> >
> > In a similar way, we could call the trigger function in net/core/de=
v.c in
> > netif_receive_skb and netif_rx ?
> >
> > I was also thinking that some network NIC already have LEDs, so it =
is not
> > necessary for those models to "overload" the user with lights every=
where.
> >
> > R
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Cordialement, Florian Fainelli
---------------------------------------------
5, rue Charles Fourier
Chambre 1202
91011 Evry
http://www.alphacore.net
(+33) 01 60 76 64 21
(+33) 06 09 02 64 95
---------------------------------------------
Association MiNET
http://www.minet.net
---------------------------------------------
Institut National des T=E9l=E9communication
http://www.int-evry.fr/telecomint
---------------------------------------------
