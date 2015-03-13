From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/6] rhashtable: Add rehash counter to bucket_table
Date: Fri, 13 Mar 2015 13:51:31 +0000
Message-ID: <20150313135131.GB17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLC-0000CE-RS@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56880 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbCMNvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:51:32 -0400
Content-Disposition: inline
In-Reply-To: <E1YWMLC-0000CE-RS@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> @@ -58,7 +59,8 @@ struct rhash_head {
>   * @buckets: size * hash buckets
>   */
>  struct bucket_table {
> -	size_t			size;
> +	unsigned int		size;
> +	unsigned int		rehash;
>  	u32			hash_rnd;
>  	u32			shift;
>  	unsigned int		locks_mask;

This changes causes a minor warning:
lib/test_rhashtable.c: In function =E2=80=98test_bucket_stats=E2=80=99:
lib/test_rhashtable.c:83:4: warning: format =E2=80=98%zu=E2=80=99 expec=
ts argument of
type =E2=80=98size_t=E2=80=99, but argument 3 has type =E2=80=98unsigne=
d int=E2=80=99 [-Wformat=3D]
    pr_info(" [%#4x/%zu]", i, tbl->size)
