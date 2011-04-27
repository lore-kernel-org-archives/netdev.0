From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] ipv4: Remove erroneous check in igmpv3_newpack()
 and igmp_send_report().
Date: Wed, 27 Apr 2011 06:50:08 +0200
Message-ID: <1303879808.2699.46.camel@edumazet-laptop>
References: <20110426.151204.70183859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57047 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab1D0EuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 00:50:13 -0400
Received: by wwa36 with SMTP id 36so1462166wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 21:50:12 -0700 (PDT)
In-Reply-To: <20110426.151204.70183859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 15:12 -0700, David Miller a =C3=A9crit :
> Output route resolution never returns a route with rt_src set to zero
> (which is INADDR_ANY).
>=20
> Even if the flow key for the output route lookup specifies INADDR_ANY
> for the source address, the output route resolution chooses a real
> source address to use in the final route.
>=20
> This test has existed forever in igmp_send_report() and David Stevens
> simply copied over the erroneous test when implementing support for
> IGMPv3.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


