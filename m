From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Sun, 27 Mar 2005 05:47:07 +1000
Message-ID: <20050326194707.GA9872@gondor.apana.org.au>
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
> +#define XFRMGRP_SA		8
> +#define XFRMGRP_POLICY		0x10

Since we're adding new multicast groups, what about adding one for
the passive event monitor? That way we can return ESRCH in km_query
if there are no registered ACQUIRE listeners but still send messages
to the monitor.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
