From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 00:24:10 +0100
Message-ID: <1289431450.17691.116.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>
	 <1289427705.17691.52.camel@edumazet-laptop>
	 <4CDB226A.8080903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43946 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757268Ab0KJXYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 18:24:15 -0500
Received: by wwi17 with SMTP id 17so906436wwi.1
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 15:24:14 -0800 (PST)
In-Reply-To: <4CDB226A.8080903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 14:53 -0800, Ben Greear a =C3=A9cri=
t :

> Then it's busted.  If it claims to return stats64, but instead is ret=
urning
> something different, it is wrong.  Netlink API still defines a stats3=
2, so
> the kernel should use that if it can't reliably deal with 64-bit coun=
ters.
>=20

It claims nothing like that. You obviously assumed wrong things.

It provides a framework, not a mandatory or exclusive one.

Really this endless discussion is going nowhere.

I suggest you send patches if you want, I am very pleased by current
stats handling.



