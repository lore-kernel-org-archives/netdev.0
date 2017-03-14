From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/3] vxlan: fix snooping for link-local IPv6
 addresses
Date: Tue, 14 Mar 2017 15:56:56 +0100
Message-ID: <20170314155656.1446a358@griffin>
References: <cover.1489184335.git.mschiffer@universe-factory.net>
        <a897a68b6a9994b0f7a1d53f6079f5e04fcec443.1489184335.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org, pshelar@ovn.org,
        aduyck@mirantis.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a897a68b6a9994b0f7a1d53f6079f5e04fcec443.1489184335.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Mar 2017 23:39:43 +0100, Matthias Schiffer wrote:
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -941,16 +941,24 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>   */
>  static bool vxlan_snoop(struct net_device *dev,
>  			union vxlan_addr *src_ip, const u8 *src_mac,
> -			__be32 vni)
> +			__u32 src_ifindex, __be32 vni)

Just "u32", please. No double underscores for u32 inside the
kernel-only code. (Also in other places in this patch.)

Thanks,

 Jiri
