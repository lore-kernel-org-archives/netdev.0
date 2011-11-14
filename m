From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 20:26:06 +0100
Message-ID: <1321298766.2719.11.camel@edumazet-laptop>
References: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111114.142153.804127798975712263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, pstaszewski@itcare.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com, therbert@google.com, hadi@mojatatu.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	herbert@gondor.hengli.com.au, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51563 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448Ab1KNT0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:26:11 -0500
Received: by wwe5 with SMTP id 5so4876794wwe.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 11:26:10 -0800 (PST)
In-Reply-To: <20111114.142153.804127798975712263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 14:21 -0500, David Miller a =C3=A9crit=
 :

> Applied, I'll work on converting NIU over to this if I find some time=
=2E

I dont believe NIU needs it, since its a frag enabled driver.

You already allocate a fresh skb (and attach frags to it) right before
giving it to upper stack.
