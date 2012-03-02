From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Patch for MTU in the routing table cache
Date: Fri, 02 Mar 2012 06:27:16 -0800
Message-ID: <1330698436.2469.27.camel@edumazet-laptop>
References: <4F50C789.8050709@istac.de>
	 <1330695791.2469.17.camel@edumazet-laptop> <4F50CFE1.5040605@istac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simeon Penev <spenev@istac.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54513 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964847Ab2CBO1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 09:27:19 -0500
Received: by pbcun15 with SMTP id un15so159211pbc.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 06:27:19 -0800 (PST)
In-Reply-To: <4F50CFE1.5040605@istac.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 mars 2012 =C3=A0 14:49 +0100, Simeon Penev a =C3=A9crit =
:
> Hi Eric,
>=20
> no, i didn't. I'm new to the developer list and just wanted to post a=
=20
> patch proposition. I hoped that the maintainer of the code (probably=20
> Alan Cox) will decide whether to use it.
>=20

David Miller is the current network maintainer, but thats not the
point :)

I didnt test your patch, all I wanted to say is that you cant assume al=
l
routes share the same MTU (device MTU)

And this is the assumption you coded :

if (mtu && rt_is_output_route(rt) && mtu =3D=3D dst->dev->mtu)
	return mtu;
