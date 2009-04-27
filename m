From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 08:47:38 +0200
Message-ID: <49F5550A.1050805@cosmosbay.com>
References: <49F53FF6.2040603@cosmosbay.com>	<20090427054702.GA15891@kryten>	<49F54CC5.7020600@cosmosbay.com> <20090426.233638.83897914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58668 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755830AbZD0Grr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:47:47 -0400
In-Reply-To: <20090426.233638.83897914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 27 Apr 2009 08:12:21 +0200
>=20
>> A similar patch was done for the size of TCP hash table. It was some=
thing
>> like 512 * 1024 if I remember well. IMHO this same value would be fi=
ne for
>> IP route cache.
>>
>> Yes, this was commit :
>=20
> Fair enough, I'd be OK with this if you'd be too :)

Yes, as setups needing more than 512.000 slots (and 2 million entries w=
ith an
average of 4 entries per slot) are certainly able to boot with an overr=
ide.

Anton, please resubmit with this 512 k limit, and my :

Acked-by: Eric Dumazet <dada1@cosmosbay.com>

 thank you.

