From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] vlan: cleanup the usage of vlan_dev_priv(dev)
Date: Fri, 02 Aug 2013 22:03:10 -0700 (PDT)
Message-ID: <20130802.220310.447316606630944097.davem@davemloft.net>
References: <51FC6492.9000001@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab3HCFDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 01:03:20 -0400
In-Reply-To: <51FC6492.9000001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Sat, 03 Aug 2013 10:01:54 +0800

> This patch cleanup 2 points for the usage of vlan_dev_priv(dev):
> * In vlan_dev.c/vlan_dev_hard_header, we should use the var *vlan
> * directly
>   after grabing the pointer at the beginning with
>        *vlan = vlan_dev_priv(dev);
>   when we need to access the fields of *vlan.
> * In vlan.c/register_vlan_device, add the var *vlan pointer
>        struct vlan_dev_priv *vlan;
>   to cleanup the code to access the fields of vlan_dev_priv(new_dev).
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> ---
>  net/8021q/vlan.c     |   12 +++++++-----
>  net/8021q/vlan_dev.c |    6 +++---
>  2 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 2fb2d88..b9d3d7e 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -210,6 +210,7 @@ out_vid_del:
>  static int register_vlan_device(struct net_device *real_dev, u16
>  vlan_id)

This still doesn't apply, because your email client corrupted
the patch.
