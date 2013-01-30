From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] net: disallow drivers with buggy VLAN accel
 to register_netdevice()
Date: Wed, 30 Jan 2013 08:36:08 -0500
Message-ID: <510921C8.9010300@redhat.com>
References: <c7fdfc32f69e7a4c3bfcaa8b2ee842aa9b286c91.1359507017.git.mirq-linux@rere.qmqm.pl> <510874B9.5000208@redhat.com> <20130129.225657.181728058877634021.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, kaber@trash.net,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab3A3NgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 08:36:16 -0500
In-Reply-To: <20130129.225657.181728058877634021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2013 10:56 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Tue, 29 Jan 2013 20:17:45 -0500
>=20
>> On 01/29/2013 08:14 PM, Micha=A9=A9 Miros=A9=A9aw wrote:
>>> Instead of jumping aroung bugs that are easily fixed just don't let
>>> them in:
>>> affected drivers should be either fixed or have NETIF_F_HW_VLAN_FIL=
TER
>>> removed from advertised features.
>>>
>>> Quick grep in drivers/net shows two drivers that have
>>> NETIF_F_HW_VLAN_FILTER
>>> but not ndo_vlan_rx_add/kill_vid(), but those are false-positives
>>> (features
>>> are commented out).
>>>
>>> OTOH two drivers have ndo_vlan_rx_add/kill_vid() implemented but do=
n't
>>> advertise NETIF_F_HW_VLAN_FILTER. Those are:
>>
>> I am a bit hesitant to completely disable drivers, but I guess it
>> would force people to fix their drivers if this is applied.
>=20
> I think an improperly implemented driver should be BUG trapped as soo=
n
> as possible.
>=20
> I've applied this patch, thanks.
>=20

OK,  I'll rebase my series on top of this and get rid the buggy calls.

Thanks
-vlad
