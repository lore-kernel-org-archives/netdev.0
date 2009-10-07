From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: extend hash tables to 256 slots
Date: Wed, 07 Oct 2009 07:33:09 +0200
Message-ID: <4ACC2815.7010101@gmail.com>
References: <4ACBE3E7.60404@hp.com>	<4ACC0CDE.1020907@gmail.com>	<4ACC1C73.1010506@gmail.com> <20091006.222935.231081303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55757 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbZJGFdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 01:33:51 -0400
In-Reply-To: <20091006.222935.231081303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> That's incredible that it's been that low for so long :-)
>=20
> Bug please, dynamically size this thing, maybe with a cap of say 64K
> to start with.  If you don't have time for it I'll take care of this.


Well, we can not exceed 65536 slots, given the nature of UDP protocol :=
)

Do you mean a static allocation at boot time with a size that can be=20
overidden in cmdline(like tcp and ip route),

or something that can dynamically extends hash table at runtime ?

