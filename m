From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [BK PATCH] [IPV6] Merge Specification Conformity Improvements
Date: Mon, 13 Sep 2004 17:29:20 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409131725250.22572-100000@netcore.fi>
References: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@davemloft.net, <netdev@oss.sgi.com>, <vnuorval@tcs.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for doing these; I hope you guys will have energy for the other 
spec fixes to come :)


One thing I noted when reading the comment:

On Mon, 13 Sep 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> +	/*
> +	 * Redirect received -> path was valid.
> +	 * Look, redirects are sent only in response to data packets,
> +	 * so that this nexthop apparently is reachable. --ANK
> +	 */
> +	dst_confirm(&rt->u.dst);
> +
> +	/* Duplicate redirect: silently ignore. */
> +	if (neigh == rt->u.dst.neighbour)
> +		goto out;

The above applies for "valid" redirects, which have been received 
based on the traffic sent.

However, if someone would be forging redirects, the comment would no 
longer hold.

I don't know the implications in this case: whether the code needs to 
have different assumptions wrt. source of redirects, or whether this 
is just a wording issue in the comment above.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
