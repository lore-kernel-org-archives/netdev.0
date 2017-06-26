From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] netfilter: conntrack: add a new
 NF_CT_EXT_EXPAND extension
Date: Mon, 26 Jun 2017 18:53:09 +0200
Message-ID: <20170626165309.GM29636@breakpoint.cc>
References: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498457446-30135-1-git-send-email-xiaolou4617@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lin Zhang <xiaolou4617@gmail.com> wrote:
>   In the current conntrack extend code, if we want to add a new
> extension, we must be add a new extension id and recompile kernel.
> I think that is not be convenient for users, so i add a new extension named
> NF_CT_EXT_EXPAND for supporting dynamic register/unregister expansion
> in runtime that means if kernel support NF_CT_EXT_EXPAND extension,
> user could call nf_ct_expand_area_add() to register a new expansion
> but not need to predefine an id in enum nf_ct_ext_id.

We never did this because its only required for out of tree modules.

I would prefer if such extensions are discussed/proposed on nf-devel
instead, and then, if there is agreement that the extension is useful,
it can be submitted for inclusion in mainline kernel instead.
