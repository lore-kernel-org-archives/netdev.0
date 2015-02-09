From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 08 Feb 2015 21:52:46 -0800 (PST)
Message-ID: <20150208.215246.2043422740922842311.davem@davemloft.net>
References: <20150209140745.24859389@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150209140745.24859389@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Feb 2015 14:07:45 +1100

> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index e96fc00208bc..9cc4c4a90d00 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -23,6 +23,7 @@
>  #include <linux/jhash.h>
>  #include <linux/random.h>
>  #include <linux/rhashtable.h>
> +#include <linux/err.h>
>  
>  #define HASH_DEFAULT_SIZE	64UL
>  #define HASH_MIN_SIZE		4UL

Applied, thanks Stephen.
