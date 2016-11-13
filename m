From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: x_tables: simplify IS_ERR_OR_NULL to NULL test
Date: Sun, 13 Nov 2016 22:27:07 +0100
Message-ID: <20161113212707.GA30418@salvia>
References: <1478867558-21650-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@namei.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Patrick McHardy <kaber@trash.net>,
        christophe.jaillet@wanadoo.fr
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478867558-21650-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2016 at 01:32:38PM +0100, Julia Lawall wrote:
> Since commit 7926dbfa4bc1 ("netfilter: don't use
> mutex_lock_interruptible()"), the function xt_find_table_lock can only
> return NULL on an error.  Simplify the call sites and update the
> comment before the function.

Applied, thanks Julia!
