From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 11:02:02 +0100
Message-ID: <1322906522.2762.108.camel@edumazet-laptop>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
	 <1322897233.2762.79.camel@edumazet-laptop>
	 <1322898902.2762.81.camel@edumazet-laptop>
	 <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
	 <1322902401.2762.85.camel@edumazet-laptop>
	 <4ED9E5FA.30204@msgid.tls.msk.ru>
	 <73da1a18b48dc3097acd6728be208c66@visp.net.lb>
	 <1322905302.2762.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49094 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab1LCKCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 05:02:06 -0500
Received: by bkbzv3 with SMTP id zv3so79247bkb.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 02:02:04 -0800 (PST)
In-Reply-To: <1322905302.2762.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 d=C3=A9cembre 2011 =C3=A0 10:41 +0100, Eric Dumazet a =C3=A9=
crit :
> [PATCH] tcp: drop SYN+FIN messages
>=20
> Denys Fedoryshchenko reported that SYN+FIN attacks were bringing his
> linux machines to their limits.
>=20
> Dont call conn_request() if the TCP flags includes SYN flag
>=20

Oh well this should be :

Dont call conn_request() if the TCP flags includes FIN flag
