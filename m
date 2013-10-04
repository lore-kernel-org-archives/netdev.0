From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: do not forget FIN in tcp_shifted_skb()
Date: Fri, 04 Oct 2013 14:17:35 -0400 (EDT)
Message-ID: <20131004.141735.1539840568193384153.davem@davemloft.net>
References: <1380907901.3564.24.camel@edumazet-glaptop.roam.corp.google.com>
	<alpine.DEB.2.02.1310042101040.32153@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55014 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3JDSRg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:17:36 -0400
In-Reply-To: <alpine.DEB.2.02.1310042101040.32153@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 4 Oct 2013 21:03:53 +0300 (EEST)

> On Fri, 4 Oct 2013, Eric Dumazet wrote:
>=20
>> From: Eric Dumazet <edumazet@google.com>
>>=20
>> Yuchung found following problem :
>>=20
>>  There are bugs in the SACK processing code, merging part in
>>  tcp_shift_skb_data(), that incorrectly resets or ignores the sacked
>>  skbs FIN flag. When a receiver first SACK the FIN sequence, and lat=
er
>>  throw away ofo queue (e.g., sack-reneging), the sender will stop
>>  retransmitting the FIN flag, and hangs forever.
>>=20
>> Following packetdrill test can be used to reproduce the bug.
 ...
> Nice that it was finally found. For some reason my memory tries to sa=
y=20
> that it wouldn't have not even tried to merge skbs with FIN but eithe=
r
> I changed that at some point while deving or I just remember wrong.
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks everyone.
