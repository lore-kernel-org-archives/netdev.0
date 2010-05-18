From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp md5 fraglist...
Date: Tue, 18 May 2010 08:30:24 +0200
Message-ID: <1274164224.2567.35.camel@edumazet-laptop>
References: <20100517.231403.148532542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:64812 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0ERGa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 02:30:28 -0400
Received: by wwi17 with SMTP id 17so226108wwi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 23:30:26 -0700 (PDT)
In-Reply-To: <20100517.231403.148532542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 23:14 -0700, David Miller a =C3=A9crit :
> Eric, would you please formally submit that tcp md5 fraglist
> fix to net/ipv4/tcp.c with proper signoffs?
>=20
> Thanks!

Sure, will do, but I doubt it is a real problem, because GRO or RSC
should not coalesce two segments with MD5 signature (they are guarantee=
d
to differ for each segment ?)



