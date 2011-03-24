From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 23:32:26 +0100
Message-ID: <1301005946.2714.130.camel@edumazet-laptop>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	 <1300980118.3747.42.camel@edumazet-laptop>
	 <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	 <1300983340.3747.44.camel@edumazet-laptop>
	 <1300986084.3747.101.camel@edumazet-laptop>
	 <AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
	 <1300992308.3747.205.camel@edumazet-laptop>
	 <AANLkTin_gxMF1hyK_yhN+G9UGfcBKAhPE24r7tLe5j3D@mail.gmail.com>
	 <1301005107.2714.113.camel@edumazet-laptop>
	 <AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61502 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757281Ab1CXWcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 18:32:32 -0400
In-Reply-To: <AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 mars 2011 =C3=A0 23:27 +0100, Alessandro Suardi a =C3=A9cri=
t :

> Don't think so. This tool has been working since I built it (29 June =
2010)
>  and still works in -git2 :)
>=20

Then it doesnt work anymore because it parses an ipip field from
ip route get ...

$ ip ro get 192.168.1.1
192.168.1.1 dev wlan0  src 192.168.1.21=20
    cache  ipid 0x784c mtu 1500 advmss 1460 hoplimit 64


Maybe you upgraded iproute2



