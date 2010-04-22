From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 09:10:33 +0200
Message-ID: <1271920233.7895.4723.camel@edumazet-laptop>
References: <1271456302.16881.4559.camel@edumazet-laptop>
	 <20100418.024601.85853662.davem@davemloft.net>
	 <1271830116.7895.1316.camel@edumazet-laptop>
	 <20100421.225625.177238009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:34099 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731Ab0DVHKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:10:45 -0400
Received: by bwz25 with SMTP id 25so9159646bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:10:43 -0700 (PDT)
In-Reply-To: <20100421.225625.177238009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 avril 2010 =C3=A0 22:56 -0700, David Miller a =C3=A9crit=
 :

> Right, I've applied this, thanks.
>=20
> What we should probably do instead is call and NULL out the
> DEV_GSO_CB() destructor.  Right?

Yes, probably, I'll take a look at this if you want.

Thanks


