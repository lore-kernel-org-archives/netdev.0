From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Patch for MTU in the routing table cache
Date: Fri, 02 Mar 2012 05:43:11 -0800
Message-ID: <1330695791.2469.17.camel@edumazet-laptop>
References: <4F50C789.8050709@istac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simeon Penev <spenev@istac.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:43057 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab2CBNnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 08:43:13 -0500
Received: by pbcun15 with SMTP id un15so120385pbc.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 05:43:13 -0800 (PST)
In-Reply-To: <4F50C789.8050709@istac.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 mars 2012 =C3=A0 14:13 +0100, Simeon Penev a =C3=A9crit =
:
> Hi,
>=20
> after testing the new 3.2 kernel and the new route caching code, i've=
=20
> found a bug in net/ipv4/route.c. The route cache does not detect chan=
ges=20
> to the MTU of the interface. Therefore IP fragmentation will happen w=
ith=20
> false MTU. Please see attached the proposed patch.
>=20

Hi

Did you test this patch doesnt break things like

ip ro add 96.17.148.89 via 10.0.0.1 mtu 800

(and keep eth0 mtu being standard mtu)
