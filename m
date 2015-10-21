From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 4/5] openvswitch: conntrack netlink API updates.
Date: Wed, 21 Oct 2015 12:41:33 +0200
Message-ID: <20151021104133.GA2135@salvia>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-4-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445379629-112880-4-git-send-email-jrajahalme@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 03:20:28PM -0700, Jarno Rajahalme wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 77850f1..1e6c2ac 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -291,7 +291,7 @@ size_t ovs_key_attr_size(void)
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
> -		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
> +		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_STATE */
>  		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
>  		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */

This is very strange.

You're changing the size of the netlink attribute, this will break
existing userspace applications.
