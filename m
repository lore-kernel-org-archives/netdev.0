From: "Jing Min Zhao" <zhaojingmin@hotmail.com>
Subject: Re: 2.6 patch] ip_conntrack_helper_h323.c: make
	get_h245_addr()static
Date: Thu, 23 Mar 2006 21:37:15 -0500
Message-ID: <BAY109-DAV122F44146DB217251703AEB3DF0@phx.gbl>
References: <20060324000916.GN22727@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "Adrian Bunk" <bunk@stusta.de>, "Jing Min Zhao" <zhaojignmin@hotmail.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


----- Original Message ----- 
From: "Adrian Bunk" <bunk@stusta.de>
To: "Jing Min Zhao" <zhaojignmin@hotmail.com>
Cc: <netdev@vger.kernel.org>; <netfilter-devel@lists.netfilter.org>; 
<linux-kernel@vger.kernel.org>
Sent: Thursday, March 23, 2006 7:09 PM
Subject: [RFC: 2.6 patch] ip_conntrack_helper_h323.c: make 
get_h245_addr()static

I'd like to keep it global. In the future we may need it.

Thanks

Jing Min Zhao

> This patch makes a needlessly global function static.
>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
> ---
>
> net/ipv4/netfilter/ip_conntrack_helper_h323.c |    5 ++---
> net/ipv4/netfilter/ip_nat_helper_h323.c       |    2 --
> 2 files changed, 2 insertions(+), 5 deletions(-)
>
> --- linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_nat_helper_h323.c.old 
> 2006-03-23 23:13:59.000000000 +0100
> +++ linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_nat_helper_h323.c 
> 2006-03-23 23:14:05.000000000 +0100
> @@ -49,8 +49,6 @@
> #define DEBUGP(format, args...)
> #endif
>
> -extern int get_h245_addr(unsigned char *data, H245_TransportAddress * 
> addr,
> - u_int32_t * ip, u_int16_t * port);
> extern int get_h225_addr(unsigned char *data, TransportAddress * addr,
>  u_int32_t * ip, u_int16_t * port);
> extern void ip_conntrack_h245_expect(struct ip_conntrack *new,
> ---  
> linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_conntrack_helper_h323.c.old 
> 2006-03-23 23:14:21.000000000 +0100
> +++ linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_conntrack_helper_h323.c 
> 2006-03-23 23:14:35.000000000 +0100
> @@ -222,8 +222,8 @@
> }
>
> /****************************************************************************/
> -int get_h245_addr(unsigned char *data, H245_TransportAddress * addr,
> -   u_int32_t * ip, u_int16_t * port)
> +static int get_h245_addr(unsigned char *data, H245_TransportAddress * 
> addr,
> + u_int32_t * ip, u_int16_t * port)
> {
>  unsigned char *p;
>
> @@ -1713,7 +1713,6 @@
> module_init(init);
> module_exit(fini);
>
> -EXPORT_SYMBOL(get_h245_addr);
> EXPORT_SYMBOL(get_h225_addr);
> EXPORT_SYMBOL(ip_conntrack_h245_expect);
> EXPORT_SYMBOL(ip_conntrack_q931_expect);
>
>
> 
