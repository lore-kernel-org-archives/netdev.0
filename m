From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe question
Date: Mon, 30 Nov 2009 14:02:08 +0100
Message-ID: <4B13C250.7020402@gmail.com>
References: <4B0BADA6.7080602@gmail.com>	<1259057164.2631.36.camel@ppwaskie-mobl2>	<4B0BDC24.1060401@intel.com> <20091129.001856.236847721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com,
	robert@herjulf.net, hawk@diku.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49640 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbZK3NCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 08:02:10 -0500
In-Reply-To: <20091129.001856.236847721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Tue, 24 Nov 2009 13:14:12 +0000
>=20
>> Believe the below patch will break DCB and FCoE though, both feature=
s
>> have the potential to set real_num_tx_queues to greater then the
>> number of CPUs.  This could result in real_num_tx_queues >
>> num_tx_queues.
>>
>> The current solution isn't that great though, maybe we should set to
>> the minimum of MAX_TX_QUEUES and num_possible_cpus() * 2 + 8.
>>
>> That should cover the maximum possible queues for DCB, FCoE and thei=
r
>> combinations.
>>
>> general multiq =3D num_possible_cpus()
>> DCB =3D 8 tx queue's
>> FCoE =3D 2*num_possible_cpus()
>> FCoE + DCB =3D 8 tx queues + num_possible_cpus
>=20
> Eric, I'm tossing your patch because of this problem, just FYI.

Sure, I guess we need a more generic way to handle this.

