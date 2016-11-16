From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Tue, 15 Nov 2016 16:56:05 -0800
Message-ID: <20161116005605.GA16285@kafai-mba.local>
References: <20161116113647.04900939@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161116113647.04900939@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 11:36:47AM +1100, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) produced this warning:
>
> kernel/bpf/bpf_lru_list.c: In function '__bpf_lru_list_rotate_inactive.isra.3':
> kernel/bpf/bpf_lru_list.c:201:28: warning: 'next' may be used uninitialized in this function [-Wmaybe-uninitialized]
>   l->next_inactive_rotation = next;
>                             ^
>
> Introduced by commit
>
>   3a08c2fd7634 ("bpf: LRU List")
>
> I can't tell if this is a false positive or not.
A false positive.

A patch has been posted: https://patchwork.ozlabs.org/patch/695202/

Thanks for the report.
--Martin
