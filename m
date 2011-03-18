From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN over GRE segfault
Date: Fri, 18 Mar 2011 09:26:32 +0100
Message-ID: <1300436792.2888.0.camel@edumazet-laptop>
References: <4D830AF9.8040007@diddi.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Diddi Oscarsson <diddi@diddi.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47674 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab1CRI0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 04:26:37 -0400
Received: by fxm17 with SMTP id 17so3456778fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 01:26:36 -0700 (PDT)
In-Reply-To: <4D830AF9.8040007@diddi.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 08:34 +0100, Diddi Oscarsson a =C3=A9cr=
it :
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hello!
>=20
> I was trying to get ethernet over GRE to work when I found an obvious
> way NOT to do it.
> Basically I created a VLAN interface from the GRE interface (even
> though I had my fair doubts it would work) which gave me a nice segfa=
ult.
> The problem with this is that after the segfault, new network
> connections cannot be made (ping, ssh, http, whatever) and a reboot o=
f
> the computer is necessary.
> I think an error message needs to be added when trying an operation
> like this.

Hmm, thanks for the report, I'll submit a patch to fix this
(NETIF_F_VLAN_CHALLENGED needed on some devices)


