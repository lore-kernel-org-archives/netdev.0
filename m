From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] netfilter: nf_ct_ext: support variable length
 extensions
Date: Tue, 12 Jun 2012 15:35:15 -0700 (PDT)
Message-ID: <20120612.153515.283446551239473288.davem@davemloft.net>
References: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
	<1339524380-2707-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339524380-2707-3-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue, 12 Jun 2012 20:06:15 +0200

> @@ -79,11 +79,16 @@ static inline void nf_ct_ext_free(struct nf_conn *ct)
>  		kfree(ct->ext);
>  }
>  
> +void *__nf_ct_ext_add_length(struct nf_conn *ct, enum nf_ct_ext_id id,
> +			     size_t var_alloc_len, gfp_t gfp);
> +
>  /* Add this type, returns pointer to data or NULL. */
>  void *
>  __nf_ct_ext_add(struct nf_conn *ct, enum nf_ct_ext_id id, gfp_t gfp);

You should remove this extern declaration for __nf_ct_ext_add() since you
are removing, or rather renaming, it in this patch.
