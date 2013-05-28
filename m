From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next 1/3] vxlan: remove the unused rcu head from
 struct vxlan_rdst
Date: Tue, 28 May 2013 09:07:06 -0700
Message-ID: <20130528090706.0d4e9bee@nehalam.linuxnetplumber.net>
References: <1369730153-11214-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:46172 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934771Ab3E1QHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 12:07:10 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so652509pad.5
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 09:07:09 -0700 (PDT)
In-Reply-To: <1369730153-11214-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 16:35:51 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  drivers/net/vxlan.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 5ed64d4..289d79a 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -97,7 +97,6 @@ struct vxlan_net {
>  };
>  
>  struct vxlan_rdst {
> -	struct rcu_head		 rcu;
>  	__be32			 remote_ip;
>  	__be16			 remote_port;
>  	u32			 remote_vni;


Correct, rdst is freed with fdb and that is already
in RCU call back

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
