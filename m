From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/4] net: netfilter conntrack - add per-net functionality
 for DCCP protocol
Date: Tue, 10 Mar 2009 04:25:37 -0700 (PDT)
Message-ID: <20090310.042537.49464370.davem@davemloft.net>
References: <20090309181628.109019157@gmail.com>
	<20090309182731.762563452@gmail.com>
	<49B63EA6.2060802@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, kaber@trash.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, xemul@openvz.org, adobriyan@gmail.com,
	gorcunov@openvz.org
To: daniel.lezcano@free.fr
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49B63EA6.2060802@free.fr>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Tue, 10 Mar 2009 11:19:18 +0100

> >  static int __init nf_conntrack_proto_dccp_init(void)
> >  {
> >  	int err;
> >  -	err = nf_conntrack_l4proto_register(&dccp_proto4);
> > +	err = register_pernet_gen_device(&dccp_net_id, &dccp_net_ops);
> >   
> 
> Shouldn't it be register_pernet_gen_subsys ?

Do I really have to carefully and meticuliously scan down
hundreds and hundreds of irrelevant quoted patch text just
to see what bit you're commenting on?

Please, just provide the necessary context of the patch for
your comments, don't quote the whole thing :-(

Thanks.
