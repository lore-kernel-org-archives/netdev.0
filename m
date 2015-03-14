From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/6] rhashtable: Add rehash counter to bucket_table
Date: Sat, 14 Mar 2015 13:49:54 +1100
Message-ID: <20150314024954.GA10525@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLC-0000CE-RS@gondolin.me.apana.org.au>
 <20150313135131.GB17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41510 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbbCNCt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:49:58 -0400
Content-Disposition: inline
In-Reply-To: <20150313135131.GB17829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 01:51:31PM +0000, Thomas Graf wrote:
> On 03/13/15 at 08:57pm, Herbert Xu wrote:
> > @@ -58,7 +59,8 @@ struct rhash_head {
> >   * @buckets: size * hash buckets
> >   */
> >  struct bucket_table {
> > -	size_t			size;
> > +	unsigned int		size;
> > +	unsigned int		rehash;
> >  	u32			hash_rnd;
> >  	u32			shift;
> >  	unsigned int		locks_mask;
>=20
> This changes causes a minor warning:
> lib/test_rhashtable.c: In function =E2=80=98test_bucket_stats=E2=80=99=
:
> lib/test_rhashtable.c:83:4: warning: format =E2=80=98%zu=E2=80=99 exp=
ects argument of
> type =E2=80=98size_t=E2=80=99, but argument 3 has type =E2=80=98unsig=
ned int=E2=80=99 [-Wformat=3D]
>     pr_info(" [%#4x/%zu]", i, tbl->size)

Thanks.  I have now enabled test_rhashtable in my config so I
should be able to catch it next time.
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
