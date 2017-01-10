From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 09:39:27 -0800
Message-ID: <20170110173927.GA75802@kafai-mba.local>
References: <1484000039-671014-1-git-send-email-kafai@fb.com>
 <2e26d5f0-fed8-a2b9-392a-87da29c38758@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56735 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1765923AbdAJRjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:39:41 -0500
Content-Disposition: inline
In-Reply-To: <2e26d5f0-fed8-a2b9-392a-87da29c38758@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 03:43:39PM +0300, Sergei Shtylyov wrote:
> Hello!
>
> On 01/10/2017 01:13 AM, Martin KaFai Lau wrote:
>
> >In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
> >it changed ENOTSUPP to EOPNOTSUPP by mistake.  This patch fixes it.
>
>    You mean vice versa (looking at your patch)?
Indeed. Will send v2 to correct this.

>
> >Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
> >Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> >---
> > drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
> > 1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >index edbe200ac2fa..4910d9af1933 100644
> >--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> >@@ -2277,7 +2277,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
> >
> > 	if (priv->tx_ring_num[TX_XDP] &&
> > 	    !mlx4_en_check_xdp_mtu(dev, new_mtu))
> >-		return -ENOTSUPP;
> >+		return -EOPNOTSUPP;
> >
> > 	dev->mtu = new_mtu;
> >
>
> MBR, Sergei
>
