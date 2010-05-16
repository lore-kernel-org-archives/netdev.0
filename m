From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Sun, 16 May 2010 21:53:28 +0200
Message-ID: <1274039609.2299.6.camel@edumazet-laptop>
References: <1273611036.2512.18.camel@edumazet-laptop>
	 <1273634421.2512.21.camel@edumazet-laptop>
	 <20100512152207.0e0c321a@nehalam>
	 <20100512.152406.193725816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Bijay.Singh@guavus.com, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55818 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab0EPUMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:12:07 -0400
Received: by wyf19 with SMTP id 19so5583wyf.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 13:12:04 -0700 (PDT)
In-Reply-To: <20100512.152406.193725816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 mai 2010 =C3=A0 15:24 -0700, David Miller a =C3=A9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 12 May 2010 15:22:07 -0700
>=20
> > Yes, that looks like a possible bug, not sure what hardware
> > generates frag_list.
>=20
> GRO generates frag_list

ixgbe (82599) too, if I understand well this driver (TCP Receive Side
Coalescing RSC)



