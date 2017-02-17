From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: vlan_tunnel: explicitly reset metadata
 attrs to NULL on failure
Date: Fri, 17 Feb 2017 10:49:20 +0100
Message-ID: <79d26bd3-ce7d-9f01-fe45-dc09017021a7@cumulusnetworks.com>
References: <1487273361-51517-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38701 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932088AbdBQJtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 04:49:23 -0500
Received: by mail-wm0-f46.google.com with SMTP id r141so6178324wmg.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 01:49:22 -0800 (PST)
In-Reply-To: <1487273361-51517-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/17 20:29, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/bridge/br_vlan_tunnel.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/bridge/br_vlan_tunnel.c b/net/bridge/br_vlan_tunnel.c
> index b2b79a0..6d2c4ee 100644
> --- a/net/bridge/br_vlan_tunnel.c
> +++ b/net/bridge/br_vlan_tunnel.c
> @@ -85,6 +85,8 @@ static int __vlan_tunnel_info_add(struct net_bridge_vlan_group *vg,
>  	return 0;
>  out:
>  	dst_release(&vlan->tinfo.tunnel_dst->dst);
> +	vlan->tinfo.tunnel_dst = NULL;
> +	vlan->tinfo.tunnel_id = 0;
>  
>  	return err;
>  }
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
