From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] question about inet_listen_lock(), and [PATCH] net: listening_hash
 get a spinlock per bucket
Date: Thu, 20 Nov 2008 09:47:26 +0100
Message-ID: <4925241E.7090505@cosmosbay.com>
References: <492199FF.3030205@cosmosbay.com> <20081120.004103.45482570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45865 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbYKTIrb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:47:31 -0500
In-Reply-To: <20081120.004103.45482570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 17 Nov 2008 17:21:19 +0100
>=20
>> [PATCH] net: listening_hash get a spinlock per bucket
>>
>> This patch prepares RCU migration of listening_hash table for
>> TCP/DCCP protocols.
>>
>> listening_hash table being small (32 slots per protocol), we add
>> a spinlock for each slot, instead of a single rwlock for whole table=
=2E
>>
>> This should reduce hold time of readers, and writers concurrency.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Ok it looks indeed as this sleeping thing was just a queer way to wai=
t
> when there was some thread dumping listening sockets.  I guess it mus=
t
> have been _really_ slow back when that was written by Alexey :)
>=20
> I've applied your patch to net-next-2.6, thanks Eric!
>=20
>=20

Thanks a lot David for your analysis, I will continue the work further.

