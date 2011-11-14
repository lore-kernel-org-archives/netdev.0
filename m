From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 20:31:12 +0100
Message-ID: <1321299072.2719.12.camel@edumazet-laptop>
References: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111114.142153.804127798975712263.davem@davemloft.net>
	 <1321298766.2719.11.camel@edumazet-laptop>
	 <20111114.142916.2005300491189237669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, pstaszewski@itcare.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com, therbert@google.com, hadi@mojatatu.com,
	shemminger@vyatta.com, tgraf@infradead.org,
	herbert@gondor.hengli.com.au, jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48644 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab1KNTbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:31:17 -0500
Received: by wwi18 with SMTP id 18so5256846wwi.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 11:31:16 -0800 (PST)
In-Reply-To: <20111114.142916.2005300491189237669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 14:29 -0500, David Miller a =C3=A9crit=
 :

> Oh I see, this is for drivers which splat the packet into a linear
> buffer to begin with.

Exact.. We have plenty of them of course :)
