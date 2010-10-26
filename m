From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Tue, 26 Oct 2010 20:57:05 +0200
Message-ID: <1288119425.2652.6.camel@edumazet-laptop>
References: <20101026.103428.179941457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, daniel.lezcano@free.fr,
	ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39342 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751Ab0JZS5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:57:10 -0400
Received: by ewy7 with SMTP id 7so5701546ewy.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:57:09 -0700 (PDT)
In-Reply-To: <20101026.103428.179941457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 10:34 -0700, David Miller a =C3=A9crit =
:
> Flush the routing cache only of entries that match the
> network namespace in which the purge event occurred.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> Could I get some testing and performance analysis feedback
> on this change?  I don't want it to just die :-)
>=20

I believe its fine, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll respin my __rcu patch, of course.



