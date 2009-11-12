From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: fold name hash properly (v3)
Date: Wed, 11 Nov 2009 19:58:22 -0800 (PST)
Message-ID: <20091111.195822.169638727.davem@davemloft.net>
References: <20091110092034.3d4ee9b0@nehalam>
	<4AF9A4C7.4010703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757252AbZKLD5z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 22:57:55 -0500
In-Reply-To: <4AF9A4C7.4010703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Nov 2009 18:37:11 +0100

> Stephen Hemminger a =E9crit :
>> The full_name_hash function does not produce well distributed values=
 in
>> the lower bits, so most code uses hash_32() to fold it.  This is rea=
lly
>> a bug introduced when name hashing was added, back in 2.5 when I add=
ed
>> name hashing.
>>=20
>> hash_32 is all that is needed since full_name_hash returns unsigned =
int
>> which is only 32 bits on 64 bit platforms.
>>=20
>> Also, there is no point in using hash_32 on ifindex, because the is =
naturally
>> sequential and usually well distributed.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
