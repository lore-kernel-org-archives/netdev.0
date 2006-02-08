From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 09 Feb 2006 10:49:37 +1100
Message-ID: <E1F6z45-0006qL-00@gondolin.me.apana.org.au>
References: <20060208232214.GC14543@mipter.zuzino.mipt.ru>
Cc: dlstevens@us.ibm.com, herbert@gondor.apana.org.au,
	carlsonj@workingcode.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: adobriyan@gmail.com (Alexey Dobriyan)
In-Reply-To: <20060208232214.GC14543@mipter.zuzino.mipt.ru>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> Oh, and for the record: current sparse from Linus doesn't warn about
> this. Slightly modified sparse warns. Bugs which were uncovered by
> more or less trivial and slightly broken sparse patch [1] are:
> 
>        [PATCH] dscc4: fix dscc4_init_dummy_skb check
>        [PATCH] opl3sa2: fix adding second dma channel
>        [PATCH] gusclassic: fix adding second dma channel
>        [PATCH] ipw2200: fix ->eeprom[EEPROM_VERSION] check
>        [PATCH] ixj: fix writing silence check

The first two can also be caught with gcc -pedantic.  In fact, catching
the last two should be doable there as well.  The difference between
gcc -pedantic and sparse is that it doesn't warn about obviously correct
cases like p != 0 or p = 0.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
