From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] IPV6: typo, unrequired #undef and killing warning
Date: Wed, 4 Jun 2003 07:08:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604070801.A7938@infradead.org>
References: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com, Ville Nuorvala <vnuorval@tcs.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030604.150218.69810413.yoshfuji@linux-ipv6.org>; from yoshfuji@linux-ipv6.org on Wed, Jun 04, 2003 at 03:02:18PM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 04, 2003 at 03:02:18PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
>  st_failure:
> -	if (fn && !(fn->fn_flags&RTN_RTINFO|RTN_ROOT))
> -		fib_repair_tree(fn);
> +	if (fn && !(fn->fn_flags&(RTN_RTINFO|RTN_ROOT)))

This still is not the right codingstyle :) it should be

	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
