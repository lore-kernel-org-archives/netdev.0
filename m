From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: Use bsearch library function
Date: Mon, 11 Sep 2017 14:30:25 -0700 (PDT)
Message-ID: <20170911.143025.555018840006192902.davem@davemloft.net>
References: <20170909031819.13622-1-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170909031819.13622-1-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas@m3y3r.de>
Date: Sat,  9 Sep 2017 05:18:19 +0200

> @@ -168,6 +169,18 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
>  	return nseq;
>  }
>  
> +static int nameseq_find_subseq_cmp(const void *key, const void *elt)
> +{
> +	u32 instance = *(u32 *)key;
> +	struct sub_seq *sseq = (struct sub_seq *)elt;

Please order local variables from longest to shortest (ie. reverse
christmas tree).

Thank you.
