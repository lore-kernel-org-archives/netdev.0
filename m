From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Thu, 07 Oct 2010 20:06:22 +0200
Message-ID: <1286474782.2427.4.camel@edumazet-laptop>
References: <1286471555.2912.291.camel@edumazet-laptop>
	 <20101007103051.63b5177c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38520 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964Ab0JGSG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 14:06:27 -0400
Received: by wyb28 with SMTP id 28so343004wyb.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 11:06:26 -0700 (PDT)
In-Reply-To: <20101007103051.63b5177c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 10:30 -0700, Stephen Hemminger a =C3=A9=
crit :

> It makes sense, but what about 256 cores and 1024 Vlans?
> That adds up to 4M of memory which is might be noticeable.
>=20
>=20

Well, 256 cores and 1024 Vlan -> 1 Mbyte of memory, not 4 ;)

This seems reasonable to me.

Eventually we could use a fallback, if percpu allocation failed -> use =
a
static field in net_device.



