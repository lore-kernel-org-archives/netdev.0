From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netdev: fold name hash properly (v3)
Date: Tue, 10 Nov 2009 18:37:11 +0100
Message-ID: <4AF9A4C7.4010703@gmail.com>
References: <20091110092034.3d4ee9b0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56981 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbZKJRhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 12:37:09 -0500
In-Reply-To: <20091110092034.3d4ee9b0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The full_name_hash function does not produce well distributed values =
in
> the lower bits, so most code uses hash_32() to fold it.  This is real=
ly
> a bug introduced when name hashing was added, back in 2.5 when I adde=
d
> name hashing.
>=20
> hash_32 is all that is needed since full_name_hash returns unsigned i=
nt
> which is only 32 bits on 64 bit platforms.
>=20
> Also, there is no point in using hash_32 on ifindex, because the is n=
aturally
> sequential and usually well distributed.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Stephen

