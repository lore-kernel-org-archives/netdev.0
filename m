From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Sun, 27 Mar 2005 05:40:06 +1000
Message-ID: <20050326194006.GA9737@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111864971.1092.904.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 02:22:51PM -0500, jamal wrote:
>
> --- a/include/linux/xfrm.h	2005/03/26 18:30:26	1.1
> +++ b/include/linux/xfrm.h	2005/03/26 18:47:48
> @@ -254,5 +254,8 @@
>  
>  #define XFRMGRP_ACQUIRE		1
>  #define XFRMGRP_EXPIRE		2
> +#define XFRMGRP_POLEXPIRE	4

Is the intention that you'll be sending policy expire messages to
POLEXPIRE only?

If so please add a new group for SA expire messages only so that
XFRMGRP_EXPIRE continues to get all expire messages for compatibility.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
