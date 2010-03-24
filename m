From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] vlan: adds vlan_dev_select_queue
Date: Wed, 24 Mar 2010 06:53:42 +0100
Message-ID: <1269410022.2915.49.camel@edumazet-laptop>
References: <20100324004116.31609.73183.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39922 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754211Ab0CXFxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 01:53:48 -0400
Received: by bwz1 with SMTP id 1so2552255bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 22:53:46 -0700 (PDT)
In-Reply-To: <20100324004116.31609.73183.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 17:41 -0700, Jeff Kirsher a =C3=A9crit :
> From: Vasu Dev <vasu.dev@intel.com>
>=20
> This is required to correctly select vlan tx queue for a driver
> supporting multi tx queue with ndo_select_queue implemented since
> currently selected vlan tx queue is unaligned to selected queue by
> real net_devce ndo_select_queue.
>=20
> Unaligned vlan tx queue selection causes thrash with higher vlan
> tx lock contention for least fcoe traffic and wrong socket tx
> queue_mapping for ixgbe having ndo_select_queue implemented.
>=20
> -v2
>=20
> As per Eric Dumazet<eric.dumazet@gmail.com> comments, mirrored
> vlan net_device_ops to have them with and without vlan_dev_select_que=
ue
> and then select according to real dev ndo_select_queue present or not
> for a vlan net_device. This is to completely skip vlan_dev_select_que=
ue
> calling for real net_device not supporting ndo_select_queue.
>=20
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Jeff



