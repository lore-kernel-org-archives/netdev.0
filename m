From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 32772] New: PROBLEM: kernel BUG at
 net/ipv4/inetpeer.c:386
Date: Wed, 06 Apr 2011 18:25:23 +0200
Message-ID: <1302107123.3209.113.camel@edumazet-laptop>
References: <20110406081818.4f0489b5@nehalam>
	 <1302105923.3209.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dimetrios@gmail.com,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63139 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab1DFQZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 12:25:27 -0400
Received: by wwa36 with SMTP id 36so1979497wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 09:25:25 -0700 (PDT)
In-Reply-To: <1302105923.3209.103.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 18:05 +0200, Eric Dumazet a =C3=A9crit=
 :

>=20
> This reminds me a possible memory corruption (from another layer)
>=20

I found the reference of a past bug report, where slub_nomerge was used
too.

 http://www.spinics.net/lists/netdev/msg154206.html



