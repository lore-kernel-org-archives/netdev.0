From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] vlan: adds vlan_dev_select_queue
Date: Wed, 24 Mar 2010 11:11:50 -0700 (PDT)
Message-ID: <20100324.111150.112828699.davem@davemloft.net>
References: <20100324004116.31609.73183.stgit@localhost.localdomain>
	<1269410022.2915.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, vasu.dev@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752193Ab0CXSL1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 14:11:27 -0400
In-Reply-To: <1269410022.2915.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Mar 2010 06:53:42 +0100

> Le mardi 23 mars 2010 =E0 17:41 -0700, Jeff Kirsher a =E9crit :
>> From: Vasu Dev <vasu.dev@intel.com>
>>=20
>> This is required to correctly select vlan tx queue for a driver
>> supporting multi tx queue with ndo_select_queue implemented since
>> currently selected vlan tx queue is unaligned to selected queue by
>> real net_devce ndo_select_queue.
>>=20
>> Unaligned vlan tx queue selection causes thrash with higher vlan
>> tx lock contention for least fcoe traffic and wrong socket tx
>> queue_mapping for ixgbe having ndo_select_queue implemented.
>>=20
>> -v2
>>=20
>> As per Eric Dumazet<eric.dumazet@gmail.com> comments, mirrored
>> vlan net_device_ops to have them with and without vlan_dev_select_qu=
eue
>> and then select according to real dev ndo_select_queue present or no=
t
>> for a vlan net_device. This is to completely skip vlan_dev_select_qu=
eue
>> calling for real net_device not supporting ndo_select_queue.
>>=20
>> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
