From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] (2/6) ipvs -- get rid of register in declarations
Date: Thu, 18 Sep 2003 00:09:52 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309180006470.15676-100000@penguin.linux-vs.org>
References: <20030916141739.22ff0101.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lvs-users@LinuxVirtualServer.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916141739.22ff0101.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hi,

If we are gonna to remove register in declarations, it is good to remove 
all of them, for example in the ip_vs_rr.c, ip_vs_wrr.c, ip_vs_wlc.c,
ip_vs_nq.c and ip_vs_sed.c.

Thanks,

Wensong

On Tue, 16 Sep 2003, Stephen Hemminger wrote:

> GCC doesn't need register in declarations (and probably ignores them).
> 
> diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> --- a/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:25 2003
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:25 2003
> @@ -279,7 +279,7 @@
>  static __inline__ unsigned
>  ip_vs_svc_hashkey(unsigned proto, __u32 addr, __u16 port)
>  {
> -	register unsigned porth = ntohs(port);
> +	unsigned porth = ntohs(port);
>  
>  	return (proto^ntohl(addr)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
>  		& IP_VS_SVC_TAB_MASK;
> @@ -482,7 +482,7 @@
>   */
>  static __inline__ unsigned ip_vs_rs_hashkey(__u32 addr, __u16 port)
>  {
> -	register unsigned porth = ntohs(port);
> +	unsigned porth = ntohs(port);
>  
>  	return (ntohl(addr)^(porth>>IP_VS_RTAB_BITS)^porth)
>  		& IP_VS_RTAB_MASK;
> diff -Nru a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
> --- a/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:08:25 2003
> +++ b/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:08:25 2003
> @@ -171,7 +171,7 @@
>  /* get weighted least-connection node in the destination set */
>  static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
>  {
> -	register struct ip_vs_dest_list *e;
> +	struct ip_vs_dest_list *e;
>  	struct ip_vs_dest *dest, *least;
>  	int loh, doh;
>  
> @@ -226,7 +226,7 @@
>  /* get weighted most-connection node in the destination set */
>  static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
>  {
> -	register struct ip_vs_dest_list *e;
> +	struct ip_vs_dest_list *e;
>  	struct ip_vs_dest *dest, *most;
>  	int moh, doh;
>  
> 
