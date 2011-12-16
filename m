From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] sch_sfq: store flow_keys in skb->cb[]
Date: Fri, 16 Dec 2011 20:31:27 +0100
Message-ID: <1324063887.2621.19.camel@edumazet-laptop>
References: <1324013979.2562.31.camel@edumazet-laptop>
	 <20111216.135420.664062202208615256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60428 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab1LPTbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:31:31 -0500
Received: by faar15 with SMTP id r15so3207527faa.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 11:31:29 -0800 (PST)
In-Reply-To: <20111216.135420.664062202208615256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 13:54 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 16 Dec 2011 06:39:39 +0100
>=20
> > Instead of using automatic flow_keys variable in sfq_hash(), use st=
orage
> > from skb->cb[] so that we can reuse it later if we want to rehash q=
ueues
> > when perturbation timer fires.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Where is "2/2"?

I got distracted by other stuff today, will finish later.

You can delete this one, I'll submit a proper serie when done.

Thanks !
