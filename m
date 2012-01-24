From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: flow_dissector.c missing include
 linux/export.h
Date: Tue, 24 Jan 2012 17:15:31 +0100
Message-ID: <1327421731.7231.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327420643.4549.113.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62877 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab2AXQPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 11:15:36 -0500
Received: by bkas6 with SMTP id s6so3589079bka.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 08:15:35 -0800 (PST)
In-Reply-To: <1327420643.4549.113.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 janvier 2012 =C3=A0 16:57 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :
> The file net/core/flow_dissector.c seems to be missing
> including linux/export.h.
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
>  net/core/flow_dissector.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 0985b9b..a225089 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -1,4 +1,5 @@
>  #include <linux/skbuff.h>
> +#include <linux/export.h>
>  #include <linux/ip.h>
>  #include <linux/ipv6.h>
>  #include <linux/if_vlan.h>


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Hmm, not sure how you found this, since export.h is included from
linux/netdevice.h (via net/netprio_cgroup.h & linux/module.h)

Or maybe you want to remove linux/module.h inclusion from
net/netprio_cgroup.h ???
