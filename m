From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V1 net-next 3/3] net/mlx4_en: Advertize DCB_CAP_DCBX_HOST
 in getdcbx
Date: Sun, 07 Apr 2013 19:31:27 +0400
Message-ID: <5161914F.8020801@cogentembedded.com>
References: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com> <1365342248-31901-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	sagig@mellanox.com, john.r.fastabend@intel.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:36055 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933930Ab3DGPc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 11:32:28 -0400
Received: by mail-la0-f45.google.com with SMTP id fn20so1229984lab.18
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 08:32:27 -0700 (PDT)
In-Reply-To: <1365342248-31901-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-04-2013 17:44, Or Gerlitz wrote:

> When our getdcbx entry is called, DCB_CAP_DCBX_HOST should be advertized too.

> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
[...]

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> index 321553f..9199aed 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> @@ -186,7 +186,7 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
>
>   static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
>   {
> -	return DCB_CAP_DCBX_VER_IEEE;
> +	return (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE);

    Nit: parens not needed here.

WBR, Sergei
