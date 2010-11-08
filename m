From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: xt_TPROXY depends on nf_defrag_ipv6_enable
Date: Mon, 08 Nov 2010 17:27:46 +0100
Message-ID: <1289233666.15376.0.camel@edumazet-laptop>
References: <20101108082534.5ea1a3ce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37631 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942Ab0KHQ1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 11:27:52 -0500
Received: by wwb18 with SMTP id 18so98962wwb.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 08:27:51 -0800 (PST)
In-Reply-To: <20101108082534.5ea1a3ce@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 08:25 -0800, Stephen Hemminger a =C3=A9=
crit :
> Current net-next-2.6 won't build for me.
>=20
> Looks like xt_TPROXY wants function only defined if NF_CONNTRACK_IPV6
> is defined.  Either TPROXY needs to select NF_CONNTRACK_IPV6 or
> the helper functions need to be refactored.=20
>=20
>   MODPOST 209 modules
> ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_socket.ko] undefined=
!
> ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_TPROXY.ko] undefined=
!
> make[1]: *** [__modpost] Error 1

This is ok in net-2.6

net-next-2.6 is not yet open.


