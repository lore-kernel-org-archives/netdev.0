From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: define NF_CT_EXT_* as needed
Date: Mon, 15 Nov 2010 12:13:09 +0100
Message-ID: <4CE115C5.20302@trash.net>
References: <1289813149-22897-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289813149-22897-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.11.2010 10:25, Changli Gao wrote:
>  #ifdef CONFIG_NF_CONNTRACK_EVENTS
> diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
> index 0772d29..1a9f96d 100644
> --- a/include/net/netfilter/nf_conntrack_extend.h
> +++ b/include/net/netfilter/nf_conntrack_extend.h
> @@ -7,10 +7,16 @@
>  
>  enum nf_ct_ext_id {
>  	NF_CT_EXT_HELPER,
> +#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)
>  	NF_CT_EXT_NAT,
> +#endif
>  	NF_CT_EXT_ACCT,
> +#ifdef CONFIG_NF_CONNTRACK_EVENTS
>  	NF_CT_EXT_ECACHE,
> +#endif
> +#ifdef CONFIG_NF_CONNTRACK_ZONES
>  	NF_CT_EXT_ZONE,
> +#endif
>  	NF_CT_EXT_NUM,

What is the purpose of #ifdef'ing the extension IDs?
