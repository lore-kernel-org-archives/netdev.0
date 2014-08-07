From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 3/5] drivers/atm/atmtcp.c: fix error return code
Date: Thu, 7 Aug 2014 09:41:16 -0400
Message-ID: <20140807094116.20efc324@thirdoffive.cmf.nrl.navy.mil>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
	<1407415749-19978-3-git-send-email-Julia.Lawall@lip6.fr>
	<20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
	<alpine.DEB.2.10.1408071530230.2337@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1408071530230.2337@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2014 15:31:05 +0200 (CEST)
Julia Lawall <julia.lawall@lip6.fr> wrote:


> diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
> index 0e3f8f9..c8e4fb4 100644
> --- a/drivers/atm/atmtcp.c
> +++ b/drivers/atm/atmtcp.c
> @@ -299,6 +299,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
>  	out_vcc = find_vcc(dev, ntohs(hdr->vpi), ntohs(hdr->vci));
>  	read_unlock(&vcc_sklist_lock);
>  	if (!out_vcc) {
> +		result = -EUNATCH;
>  		atomic_inc(&vcc->stats->tx_err);
>  		goto done;
>  	}
> 

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
