From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v12 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Fri, 01 Oct 2010 00:14:39 -0700 (PDT)
Message-ID: <20101001.001439.85411154.davem@davemloft.net>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
	<59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
	<f2bf65a8a7676bbd3e8a749ae93d99e88671d35d.1285853725.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	herbert@gondor.apana.org.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f2bf65a8a7676bbd3e8a749ae93d99e88671d35d.1285853725.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiaohui.xin@intel.com
Date: Thu, 30 Sep 2010 22:04:23 +0800

> @@ -197,10 +197,11 @@ struct skb_shared_info {
>  	union skb_shared_tx tx_flags;
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
> -	skb_frag_t	frags[MAX_SKB_FRAGS];
>  	/* Intermediate layers must ensure that destructor_arg
>  	 * remains valid until skb destructor */
>  	void *		destructor_arg;
> +
> +	skb_frag_t	frags[MAX_SKB_FRAGS];
>  };
>  
>  /* The structure is for a skb which pages may point to

Why are you moving frags[] to the end like this?
