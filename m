From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] nodmask.h: remove macro any_online_node
Date: Thu, 7 Jan 2010 08:51:46 +0900
Message-ID: <20100107085146.59cc9888.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001061624.59118.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org,
	lee.schermerhorn-VXdhtT5mjnY@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
	paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, miltonm-ogEGBHC/i9Y@public.gmane.org,
	nfont-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org, geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	Ricardo.Labiaga-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
To: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201001061624.59118.hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Jan 2010 16:24:58 -0700
H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org> wrote:

> nodmask.h: remove macro any_online_node
> 
> The macro any_online_node is prone to producing sparse warnings
> due to the local symbol 'node'. Since all the in-tree users are really
> requesting the first online node (the mask argument is either
> NODE_MASK_ALL or node_online_map) just use the first_online_node
> macro and remove the any_online_node macro since there are no users.
> 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Thank you.
BTW, it's better to add diffstat to this kind of changes.

Regards,
-Kame

> Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
> Cc: Lee Schermerhorn <lee.schermerhorn-VXdhtT5mjnY@public.gmane.org>
> Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
> Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Cc: Milton Miller <miltonm-ogEGBHC/i9Y@public.gmane.org>
> Cc: Nathan Fontenot <nfont-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
> Cc: Geoff Levand <geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
> Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Benny Halevy <bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
> Cc: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Ricardo Labiaga <Ricardo.Labiaga-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index b037d95..64c0022 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -451,7 +451,7 @@ static int __cpuinit numa_setup_cpu(unsigned long lcpu)
>  	nid = of_node_to_nid_single(cpu);
>  
>  	if (nid < 0 || !node_online(nid))
> -		nid = any_online_node(NODE_MASK_ALL);
> +		nid = first_online_node;
>  out:
>  	map_cpu_to_node(lcpu, nid);
>  
> @@ -1114,7 +1114,7 @@ int hot_add_scn_to_nid(unsigned long scn_addr)
>  	int nid, found = 0;
>  
>  	if (!numa_enabled || (min_common_depth < 0))
> -		return any_online_node(NODE_MASK_ALL);
> +		return first_online_node;
>  
>  	memory = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
>  	if (memory) {
> @@ -1125,7 +1125,7 @@ int hot_add_scn_to_nid(unsigned long scn_addr)
>  	}
>  
>  	if (nid < 0 || !node_online(nid))
> -		nid = any_online_node(NODE_MASK_ALL);
> +		nid = first_online_node;
>  
>  	if (NODE_DATA(nid)->node_spanned_pages)
>  		return nid;
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index 454997c..c4fa64b 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -69,8 +69,6 @@
>   * int node_online(node)		Is some node online?
>   * int node_possible(node)		Is some node possible?
>   *
> - * int any_online_node(mask)		First online node in mask
> - *
>   * node_set_online(node)		set bit 'node' in node_online_map
>   * node_set_offline(node)		clear bit 'node' in node_online_map
>   *
> @@ -467,15 +465,6 @@ static inline int num_node_state(enum node_states state)
>  #define node_online_map 	node_states[N_ONLINE]
>  #define node_possible_map 	node_states[N_POSSIBLE]
>  
> -#define any_online_node(mask)			\
> -({						\
> -	int node;				\
> -	for_each_node_mask(node, (mask))	\
> -		if (node_online(node))		\
> -			break;			\
> -	node;					\
> -})
> -
>  #define num_online_nodes()	num_node_state(N_ONLINE)
>  #define num_possible_nodes()	num_node_state(N_POSSIBLE)
>  #define node_online(node)	node_state((node), N_ONLINE)
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 538ca43..832c1fe 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -133,7 +133,7 @@ svc_pool_map_choose_mode(void)
>  		return SVC_POOL_PERNODE;
>  	}
>  
> -	node = any_online_node(node_online_map);
> +	node = first_online_node;
>  	if (nr_cpus_node(node) > 2) {
>  		/*
>  		 * Non-trivial SMP, or CONFIG_NUMA on
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
