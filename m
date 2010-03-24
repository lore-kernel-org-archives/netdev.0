From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] vlan: updates vlan real_num_tx_queues
Date: Wed, 24 Mar 2010 07:44:07 +0100
Message-ID: <1269413047.2915.98.camel@edumazet-laptop>
References: <20100324004116.31609.73183.stgit@localhost.localdomain>
	 <20100324004204.31609.55285.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39192 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab0CXGoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:44:13 -0400
Received: by bwz1 with SMTP id 1so2571540bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 23:44:11 -0700 (PDT)
In-Reply-To: <20100324004204.31609.55285.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 17:42 -0700, Jeff Kirsher a =C3=A9crit :
> From: Vasu Dev <vasu.dev@intel.com>
>=20
> Updates real_num_tx_queues in case underlying real device
> has changed real_num_tx_queues.
>=20
> -v2
>  As per Eric Dumazet<eric.dumazet@gmail.com> comment:-
>    -- adds BUG_ON to catch case of real_num_tx_queues exceeding num_t=
x_queues.
>    -- created this self contained patch to just update real_num_tx_qu=
eues.
>=20
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Jeff  and Vasu :)

>  net/8021q/vlan.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 4535122..db783d7 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -378,6 +378,8 @@ static void vlan_transfer_features(struct net_dev=
ice *dev,
>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>  	vlandev->fcoe_ddp_xid =3D dev->fcoe_ddp_xid;
>  #endif
> +	vlandev->real_num_tx_queues =3D dev->real_num_tx_queues;
> +	BUG_ON(vlandev->real_num_tx_queues > vlandev->num_tx_queues);
> =20
>  	if (old_features !=3D vlandev->features)
>  		netdev_features_change(vlandev);
>=20


