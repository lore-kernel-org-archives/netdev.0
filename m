From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.5.73
Date: Mon, 21 Jul 2003 05:17:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030721051733.2f2e9fb7.davem@redhat.com>
References: <20030718.004701.11546819.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307171716160.9419-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0307171716160.9419-100000@DYN318430.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jul 2003 17:37:18 -0700 (PDT)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> ------------------- Patch for prefix list against 2.5.73 ------------

Ok, I tried to apply this, but it had lots of rejects, here
is why.

> diff -ruN linux-2.5.73.org/net/ipv6/addrconf.c test/linux-2.5.73/net/ipv6/addrconf.c
> --- linux-2.5.73.org/net/ipv6/addrconf.c	2003-06-22 11:33:17.000000000 -0700
> +++ test/linux-2.5.73/net/ipv6/addrconf.c	2003-07-17 16:59:17.000000000 -0700
 ...
> @@ -1330,7 +1330,8 @@
>  		}
>  	} else if (pinfo->onlink && valid_lft) {
>  		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,

The "pinfo->onlink" part of this if test does not exist
in the sources, so patch application failed.

You're mixing this patch up with other changes in your
tree already.

Please repatch against current 2.6.x sources.
Thanks.
