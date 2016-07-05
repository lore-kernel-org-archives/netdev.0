From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] xfrm: fix crash in XFRM_MSG_GETSA netlink handler
Date: Tue, 5 Jul 2016 12:14:12 +0200
Message-ID: <577B8874.5060904@6wind.com>
References: <1467706688-3631-1-git-send-email-vegard.nossum@oracle.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Vegard Nossum <vegard.nossum@oracle.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36189 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754387AbcGEKOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 06:14:15 -0400
Received: by mail-wm0-f51.google.com with SMTP id f126so131077787wma.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 03:14:15 -0700 (PDT)
In-Reply-To: <1467706688-3631-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/07/2016 10:18, Vegard Nossum a =C3=A9crit :
> If we hit any of the error conditions inside xfrm_dump_sa(), then
> xfrm_state_walk_init() never gets called. However, we still call
> xfrm_state_walk_done() from xfrm_dump_sa_done(), which will crash
> because the state walk was never initialized properly.
>=20
> We can fix this by setting cb->args[0] only after we've processed the
> first element and checking this before calling xfrm_state_walk_done()=
=2E
>=20
> Fixes: d3623099d3 ("ipsec: add support of limited SA dump")
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thank you for the fix!
