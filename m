From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 01 May 2009 18:48:30 +0200
Message-ID: <49FB27DE.6090002@cosmosbay.com>
References: <20090430.070811.260649067.davem@davemloft.net>	<606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>	<49FA932B.4030405@cosmosbay.com> <20090501.090815.262436244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@whydna.net, jelaas@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55544 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbZEAQsj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 12:48:39 -0400
In-Reply-To: <20090501.090815.262436244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 01 May 2009 08:14:03 +0200
>=20
>> [PATCH] net: skb_tx_hash() improvements
>>
>> When skb_rx_queue_recorded() is true, we dont want to use jash distr=
ibution
>> as the device driver exactly told us which queue was selected at RX =
time.
>> jhash makes a statistical shuffle, but this wont work with 8 static =
inputs.
>>
>> Later improvements would be to compute reciprocal value of real_num_=
tx_queues
>> to avoid a divide here. But this computation should be done once,
>> when real_num_tx_queues is set. This needs a separate patch, and a n=
ew
>> field in struct net_device.
>>
>> Reported-by: Andrew Dickinson <andrew@whydna.net>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Applied, except that I changed the commit message header line to more
> reflect that this is in fact a bug fix.
>=20
> BTW, you don't need the reciprocol when num-tx-queues <=3D num-rx-que=
ues
> (you can just use the RX queue recording as the hash, straight) and
> that's the kind of check what I intended to add to net-2.6 had you no=
t
> beaten me to this patch.
>=20
> Also, thanks for giving me absolutely no credit for this whole thing
> in your commit message.  I know I do that to you all the time :-/ How
> can you forget so quickly that I'm the one that even suggested the
> exact code change for Andrew to test in the first place?

Hoho, your Honor, I am totaly guilty and sorry, sometime I think I am
David Miller, silly me ! :)

I am not fighting for credit or whatever, certainly not with you.


