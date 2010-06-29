From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -next] ixgbe: use NETIF_F_LRO
Date: Tue, 29 Jun 2010 11:00:09 -0700
Message-ID: <AANLkTikI4sf7Z0nwNoknk-BF3j9iBMUrQhWuT9O6iBLV@mail.gmail.com>
References: <20100629163857.0dcc1245@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46800 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579Ab0F2SAK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 14:00:10 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so1621946fxm.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 11:00:10 -0700 (PDT)
In-Reply-To: <20100629163857.0dcc1245@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 07:38, Stanislaw Gruszka <sgruszka@redhat.com> =
wrote:
> Both ETH_FLAG_LRO and NETIF_F_LRO have the same value, but NETIF_F_LR=
O
> is intended to use with netdev->features.
>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ix=
gbe_ethtool.c
> index 873b45e..e2ab4ae 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> @@ -2227,7 +2227,7 @@ static int ixgbe_set_flags(struct net_device *n=
etdev, u32 data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (!ad=
apter->rx_itr_setting) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 netdev->features &=3D ~ETH_FLAG_LRO;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 netdev->features &=3D ~NETIF_F_LRO;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (data & ETH_FLAG_LRO)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e_info("rx-usecs set to 0, "
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"=
LRO/RSC cannot be enabled.\n");
> --

Thanks, I have added it to my queue of patches.

--=20
Cheers,
Jeff
