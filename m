From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/7] implementation of eBPF maps
Date: Tue, 18 Nov 2014 15:39:53 -0500 (EST)
Message-ID: <20141118.153953.1397340325201477025.davem@davemloft.net>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Thu, 13 Nov 2014 17:36:43 -0800

> v1->v2:
> renamed flags for MAP_UPDATE_ELEM command to be more concise,
> clarified commit logs and improved comments in patches 1,3,7
> per discussions with Daniel
>  
> Old v1 cover:
> 
> this set of patches adds implementation of HASH and ARRAY types of eBPF maps
> which were described in manpage in commit b4fc1a460f30("Merge branch 'bpf-next'")
> 
> The difference vs previous version of these patches from August:
> - added 'flags' attribute to BPF_MAP_UPDATE_ELEM
> - in HASH type implementation removed per-map kmem_cache.
>   I was doing kmem_cache_create() for every map to enable selective slub
>   debugging to check for overflows and leaks. Now it's not needed, so just
>   use normal kmalloc() for map elements.
> - added ARRAY type which was mentioned in manpage, but wasn't public yet
> - added map testsuite and removed temporary bits from test_stubs
> 
> Note, eBPF programs cannot be attached to events yet.
> It will come in the next set.

Series applied, thanks Alexei.
