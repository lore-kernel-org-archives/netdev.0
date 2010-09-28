From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2.6] myri10ge: DCA update
Date: Tue, 28 Sep 2010 16:21:23 +0200
Message-ID: <1285683683.3154.66.camel@edumazet-laptop>
References: <4CA1F06E.3070109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Loic Prylli <loic@myri.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56111 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006Ab0I1OWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 10:22:06 -0400
Received: by fxm3 with SMTP id 3so2617659fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 07:22:05 -0700 (PDT)
In-Reply-To: <4CA1F06E.3070109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 09:41 -0400, Andrew Gallatin a =C3=A9=
crit :
> This patch contains the following DCA improvements to myri10ge:
>=20
> 1) Finally move myri10ge to use dca3 API
>=20
> 2) Disable PCIe relaxed ordering when enabling DCA on
>      myri10ge.  This provides a performance boost on Nehalem
>      based Xeons
>=20
> 3) Make sure to properly initialize NIC's DCA state when it is enable=
d,
>      rather than giving the NIC a bogus tag (0) and waiting for
>      the first received packet to trigger an update.  Not using a
>      real tag can cause hardware exceptions on some motherboards
>      when a CPU socket is empty.
>=20
> 3) Always update the cached CPU when our interrupt affinity changes
>      so as to avoid excessive calls to dca3_get_tag()
>=20
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> Signed-off-by: Loic Prylli <loic@myri.com>

ERROR: return is not a function, parentheses are not required
#99: FILE: drivers/net/myri10ge/myri10ge.c:1086:
+		return (0);

ERROR: trailing whitespace
#108: FILE: drivers/net/myri10ge/myri10ge.c:1095:
+^Ireturn (ret);^I$

ERROR: return is not a function, parentheses are not required
#108: FILE: drivers/net/myri10ge/myri10ge.c:1095:
+	return (ret);=09

total: 3 errors, 0 warnings, 71 lines checked


