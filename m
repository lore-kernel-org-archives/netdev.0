From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Thu, 03 Sep 2009 03:05:54 +0200
Message-ID: <4A9F1672.2060304@gmail.com>
References: <4A9EBF9C.2030904@gmail.com>	<20090902120107.15146e4e@nehalam>	<4A9EC383.4070304@gmail.com> <20090902.180401.155663057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, brian.haley@hp.com, kaber@trash.net,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55050 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbZICBF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 21:05:59 -0400
In-Reply-To: <20090902.180401.155663057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Sep 2009 21:12:03 +0200
>=20
>> [PATCH net-next-2.6] vlan: multiqueue vlan device
>>
>> vlan devices are currently not multi-queue capable.
>>
>> We can do that with a new rtnl_link_ops method,
>> get_tx_queues(), called from rtnl_create_link()
>>
>> This new method gets num_tx_queues/real_num_tx_queues
>> from real device.
>>
>> register_vlan_device() is also handled.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, but now I need you to do an audit :-)
>=20
> I believe that drivers will change the number of TX queues
> in use at times where we'll need to trigger an event or
> something so that vlan's can learn about the value changing.

Yes, I know :)

This is why I kept both num_tx_queues and real_num_tx_queues values,
and not the later :)

Thanks
