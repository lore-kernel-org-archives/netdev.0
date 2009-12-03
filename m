From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Introduce realloc_netdev_mq()
Date: Thu, 03 Dec 2009 18:05:39 +0100
Message-ID: <4B17EFE3.4080301@gmail.com>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net> <20091203143918.GA20526@ff.dom.local> <4B17D697.8000105@gmail.com> <20091203163640.GA2584@ami.dom.local> <20091203165449.GA2960@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33755 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbZLCRFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 12:05:40 -0500
In-Reply-To: <20091203165449.GA2960@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Thu, Dec 03, 2009 at 05:36:40PM +0100, Jarek Poplawski wrote:
>> On Thu, Dec 03, 2009 at 04:17:43PM +0100, Eric Dumazet wrote:
>>> if (realloc_netdev_mq(dev, real_queues))
>>> 	dev->real_num_tx_queues =3D real_queues;
>>>
>>> In this case the memory error is not fatal.
>> Good point! We can consider doing this inside the function too?
>=20
> Hmm... Of course, not exactly this - I mean using min().

Sure, allowing to reduce the count in case new allocation failed.

And report an error if caller wanted to increase number of queues and a=
llocation failed.
