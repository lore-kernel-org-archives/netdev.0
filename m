From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv6: RCU changes in ipv6_get_mtu() and
 ip6_dst_hoplimit()
Date: Tue, 15 Jun 2010 08:12:37 +0200
Message-ID: <1276582357.30434.332.camel@edumazet-laptop>
References: <1276526780.2478.101.camel@edumazet-laptop>
	 <4C164840.5010900@yoshifuji.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42866 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab0FOGMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:12:44 -0400
Received: by wwb18 with SMTP id 18so4456730wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 23:12:42 -0700 (PDT)
In-Reply-To: <4C164840.5010900@yoshifuji.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 00:18 +0900, YOSHIFUJI Hideaki a =C3=A9cri=
t :
> (2010/06/14 23:46), Eric Dumazet wrote:
> > Use RCU to avoid atomic ops on idev refcnt in ipv6_get_mtu()
> > and ip6_dst_hoplimit()
> >
> > Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> --yoshfuji

Gah, sorry not having CC you at least for ipv6 stuff !

Thanks !



