From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: ipv4: nf_defrag: constify nf_hook_ops
Date: Sat, 26 Aug 2017 12:45:58 +0200
Message-ID: <20170826104558.GB29355@breakpoint.cc>
References: <7859bbf3c48bf4dc16bc3e55067e01f72aceb71f.1503743850.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        linux-kernel@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7859bbf3c48bf4dc16bc3e55067e01f72aceb71f.1503743850.git.arvind.yadav.cs@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:
> nf_hook_ops are not supposed to change at runtime. nf_register_net_hooks
> and nf_unregister_net_hooks are working with const nf_hook_ops.
> So mark the non-const nf_hook_ops structs as const.

please update your nf-next tree, all nf_hook_ops are suppoed
to be const already.
