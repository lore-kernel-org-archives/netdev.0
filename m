From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 25/29] netfilter, kbuild: use canonical method to
 specify objs.
Date: Fri, 30 Jun 2017 11:17:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD002E9F3@AcuExch.aculab.com>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
 <1498776807-11124-26-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-26-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso
> Sent: 29 June 2017 23:53
> Should use ":=" instead of "+=".
...
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index c9b78e7b342f..913380919301 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -70,10 +70,9 @@ obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
>  obj-$(CONFIG_NF_DUP_NETDEV)	+= nf_dup_netdev.o
> 
>  # nf_tables
> -nf_tables-objs += nf_tables_core.o nf_tables_api.o nf_tables_trace.o
> -nf_tables-objs += nft_immediate.o nft_cmp.o nft_range.o
> -nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
> -nf_tables-objs += nft_lookup.o nft_dynset.o
> +nf_tables-objs := nf_tables_core.o nf_tables_api.o nf_tables_trace.o \
> +		  nft_immediate.o nft_cmp.o nft_range.o nft_bitwise.o \
> +		  nft_byteorder.o nft_payload.o nft_lookup.o nft_dynset.o

Why?
My preference is to add each file on its own line.
Generates much less churn when files are added or removed.

	David

