From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Tue, 15 Nov 2016 15:39:34 +0100
Message-ID: <20161115153934.363e176d@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-5-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752600AbcKOOjh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:39:37 -0500
In-Reply-To: <1479098638-4921-5-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Nov 2016 20:43:55 -0800, Pravin B Shelar wrote:
> @@ -1929,8 +1951,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  	union vxlan_addr *src;
>  	struct vxlan_metadata _md;
>  	struct vxlan_metadata *md = &_md;
> -	struct dst_entry *ndst = NULL;
>  	__be16 src_port = 0, dst_port;
> +	struct dst_entry *ndst = NULL;
>  	__be32 vni, label;
>  	__be16 df = 0;
>  	__u8 tos, ttl;

This looks kind of arbitrary. You might want to remove this hunk or
merge it to patch 3.

Other than that,
Acked-by: Jiri Benc <jbenc@redhat.com>
