From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/15] netfilter: add namespace support for l4proto
Date: Wed, 6 Jun 2012 01:56:00 +0200
Message-ID: <20120605235600.GB27222@1984>
References: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1338275063-11711-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1338275063-11711-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 29, 2012 at 03:04:09PM +0800, Gao feng wrote:
> From: Gao feng <gaofeng@cn.fujitus.com>
> 
> struct nf_proto_net stroes proto's ctl_table_header and ctl_table,
> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
> because AF_INET6's protocols need not do compat, so register or
> unregister sysctl when l4proto.l3proto != AF_INET6.
> 
> - the net_id field is used to store the pernet_operations id
>   that belones to l4proto.
> 
> - init_net will be used to initial the proto's pernet data
> 
> - nf_ct_(un)register_sysctl are changed to support net namespace,
>   use (un)register_net_sysctl_table replaces (un)register_sysctl_paths.
>   and in nf_ct_unregister_sysctl,kfree table only when users is 0.
> 
> - Add the struct net as param of nf_conntrack_l4proto_(un)register.
>   register or unregister the l4proto only when the net is init_net.
> 
> - nf_conntrack_l4proto_register call init_net to initial the pernet
>   data of l4proto.
> 
> - nf_ct_l4proto_net is used to get the pernet data of l4proto.
> 
> - use init_net as a param of nf_conntrack_l4proto_(un)register.

I have applied this patchset, but I had to rewrite the patch
descriptions.

I don't blame your English neither your writing abilities (I'm not
native speaker and not that good at writing either) but I think you
can make it better next time.

Basically, you don't need to comment every single change that the
patch does. That's easy to see by looking at the patchset.

Instead, just provide brief explanation on your intentions with the
patch, clarify things that may look not obvious to the reviewer and
what we'll get with this.
