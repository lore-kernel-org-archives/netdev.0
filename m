From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Thu, 28 May 2015 11:51:15 -0700
Message-ID: <1432839075.1556.4.camel@perches.com>
References: <20150528220607.67a68696@canb.auug.org.au>
	 <20150528.114203.717794268051352731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150528.114203.717794268051352731.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-28 at 11:42 -0700, David Miller wrote:
> I've applied the following to net-next, thanks for your report.
> 
> ====================
> [PATCH] treewide: Add missing vmalloc.h inclusion.
> 
> All of these files were only building on non-x86 because of
> the indirect of inclusion of vmalloc.h by, of all things,
> "net/inet_hashtables.h"
[]
> diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
[]
> @@ -444,6 +444,7 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
>  			err = skcipher_wait_for_data(sk, flags);
>  			if (err)
>  				goto unlock;
> +			used = ctx->used;

huh?
