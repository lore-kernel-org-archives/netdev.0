From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Mon, 02 Nov 2009 14:03:21 +0100
Message-ID: <4AEED899.9040106@gmail.com>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net> <20091102130223.GB7790@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33607 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762AbZKBNDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 08:03:23 -0500
In-Reply-To: <20091102130223.GB7790@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Mon, Nov 02, 2009 at 04:39:07AM -0800, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Mon, 2 Nov 2009 12:30:29 +0000
>>
>>> Right, but it's not a 50% chance, I guess? A user most of the time
>>> gets consistently multiqueue or non-multiqueue behavior after open,
>>> unless I miss something. Then such an exceptional state could be
>>> handled by real_num_tx_queues (just like in case of powered of cpus=
).
>>> The main difference is to hold in num_tx_queues something that is
>>> really available vs max possible value for all configs.
>> I see your point, yes this would seem to be a reasonable way
>> to start handling num_tx_queues and real_num_tx_queues.
>=20
> Very nice! So, I hope Eric should be satisfied with these requested
> comments already :-)
>=20
Sure, but I prefer a patch from you ;)

