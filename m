From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9] address family not supported for sendmsg()
Date: Thu, 21 Oct 2004 22:58:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021225820.72d278c7.davem@davemloft.net>
References: <21A5F45EFF209A44B3057E35CE1FE6E403981824-100000@eammlex037.lmc.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Suresh Krishnan <suresh.krishnan@ericsson.ca>
In-Reply-To: <21A5F45EFF209A44B3057E35CE1FE6E403981824-100000@eammlex037.lmc.ericsson.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 00:27:14 -0400 (EDT)
Suresh Krishnan <suresh.krishnan@ericsson.ca> wrote:

> --- linux-2.6.9/net/ipv6/udp.c  2004-10-18 17:54:55.000000000 -0400
> +++ linux-2.6.9-patched/net/ipv6/udp.c  2004-10-21 16:37:52.000000000 -0400
> @@ -699,7 +699,7 @@
>                 if (likely(up->pending)) {
>                         if (unlikely(up->pending != AF_INET6)) {
>                                 release_sock(sk);
> -                               return -EINVAL;
> +                               return -EAFNOSUPPORT;

I think this case should remain -EINVAL.
