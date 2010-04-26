From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Mon, 26 Apr 2010 10:41:11 +0200
Message-ID: <1272271271.2346.16.camel@edumazet-laptop>
References: <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <20100419.141947.129754682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44422 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab0DZIlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 04:41:18 -0400
Received: by bwz19 with SMTP id 19so19303bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 01:41:17 -0700 (PDT)
In-Reply-To: <20100419.141947.129754682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 14:19 -0700, David Miller a =C3=A9crit :

>=20
> I was thinking also about how we could compute rxhash in the
> loopback driver :-)

This would be easy if rxhash was not a "struct inet_sock" field but a
"struct sock" one

sock_alloc_send_pskb() (or skb_set_owner_w())

skb->rxhash =3D sk->rxhash;



