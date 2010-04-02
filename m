From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Fri, 02 Apr 2010 15:51:12 +0200
Message-ID: <1270216272.11099.3.camel@edumazet-laptop>
References: <1268765284.2932.17.camel@edumazet-laptop>
	 <20100325113038.GA3471@swordfish.minsk.epam.com>
	 <1270037311.2103.17.camel@edumazet-laptop>
	 <20100401.184345.85529643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergey.senozhatsky@gmail.com, oleg@redhat.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:44048 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947Ab0DBNvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 09:51:25 -0400
Received: by bwz9 with SMTP id 9so1613966bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 06:51:24 -0700 (PDT)
In-Reply-To: <20100401.184345.85529643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 avril 2010 =C3=A0 18:43 -0700, David Miller a =C3=A9crit :

> Applied to net-next-2.6, but:
>=20
> > +/*
> > + * Warning : rtl8169_rx_interrupt() might be called :
> > + * 1) from NAPI (softirq) context
> > + *	(polling =3D 1 : we should call netif_receive_skb())
> > + * 2) from process context (rtl8169_reset_task())
> > + *	(polling =3D 0 : we must call netif_rx() instead)
> > + */	=09
>       ^^^^^^^^
>=20
> Trailing whitespace I had to delete.

Thanks David


