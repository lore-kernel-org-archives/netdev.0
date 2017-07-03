From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the arm64
 tree
Date: Mon, 03 Jul 2017 09:54:50 +0200
Message-ID: <5959F84A.8040808@iogearbox.net>
References: <20170703113732.6af8235d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Will Deacon <will.deacon@arm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170703113732.6af8235d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/03/2017 03:37 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    arch/arm64/net/bpf_jit_comp.c
>
> between commit:
>
>    425e1ed73e65 ("arm64: fix endianness annotation for 'struct jit_ctx' and friends")
>
> from the arm64 tree and commit:
>
>    f1c9eed7f437 ("bpf, arm64: take advantage of stack_depth tracking")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me, thanks!
