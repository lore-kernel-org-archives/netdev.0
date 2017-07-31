From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1 v2] netfilter: constify nf_conntrack_l3/4proto
 parameters
Date: Mon, 31 Jul 2017 20:44:37 +0200
Message-ID: <20170731184437.GA12928@salvia>
References: <1501443524-13201-1-git-send-email-Julia.Lawall@lip6.fr>
 <1501443524-13201-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501443524-13201-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia,

On Sun, Jul 30, 2017 at 09:38:44PM +0200, Julia Lawall wrote:
> When a nf_conntrack_l3/4proto parameter is not on the left hand side
> of an assignment, its address is not taken, and it is not passed to a
> function that may modify its fields, then it can be declared as const.
> 
> This change is useful from a documentation point of view, and can
> possibly facilitate making some nf_conntrack_l3/4proto structures const
> subsequently.
> 
> Done with the help of Coccinelle.
> 
> Some spacing adjusted to fit within 80 characters.

patching file include/net/netfilter/nf_conntrack_l3proto.h
Hunk #1 FAILED at 76.
1 out of 1 hunk FAILED -- saving rejects to file
include/net/netfilter/nf_conntrack_l3proto.h.rej
patching file include/net/netfilter/nf_conntrack_l4proto.h
patching file include/net/netfilter/nf_conntrack_timeout.h
patching file net/netfilter/nf_conntrack_core.c
Hunk #1 succeeded at 1176 (offset -7 lines).
Hunk #2 succeeded at 1288 (offset -7 lines).
patching file net/netfilter/nf_conntrack_netlink.c
patching file net/netfilter/nf_conntrack_proto.c
Hunk #2 FAILED at 242.
Hunk #3 FAILED at 271.
Hunk #4 succeeded at 257 with fuzz 1 (offset -29 lines).
Hunk #5 succeeded at 272 (offset -29 lines).
Hunk #6 succeeded at 295 (offset -29 lines).
Hunk #7 succeeded at 366 (offset -29 lines).
Hunk #8 succeeded at 391 (offset -29 lines).
Hunk #9 succeeded at 404 (offset -29 lines).
Hunk #10 succeeded at 415 (offset -29 lines).
Hunk #11 succeeded at 449 (offset -29 lines).
Hunk #12 succeeded at 485 (offset -29 lines).
2 out of 12 hunks FAILED -- saving rejects to file
net/netfilter/nf_conntrack_proto.c.rej
patching file net/netfilter/nfnetlink_cttimeout.c

Could you rebase on top of nf-next git tree?

Thanks a lot!
