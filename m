From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inetpeer with create==0
Date: Thu, 03 Mar 2011 08:39:37 +0100
Message-ID: <1299137977.2456.15.camel@edumazet-laptop>
References: <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
	 <20110302.213634.189680857.davem@davemloft.net>
	 <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
	 <20110302.224220.179921025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58852 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756715Ab1CCHjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 02:39:41 -0500
Received: by fxm17 with SMTP id 17so827473fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 23:39:40 -0800 (PST)
In-Reply-To: <20110302.224220.179921025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 22:42 -0800, David Miller a =C3=A9crit =
:
> Actually, back to the original topic, I wonder how bad it is to simpl=
y
> elide the recheck in the create=3D=3D0 case anyways.  Except for the =
ipv4
> fragmentation wraparound protection values, perfect inetpeer finding
> is not necessary for correctness.  And IPv4 fragmentation always call=
s
> inetpeer with create!=3D0.
>=20

We could use a seqlock, to detect that a writer might have changed
things while we did our RCU lookup ?



