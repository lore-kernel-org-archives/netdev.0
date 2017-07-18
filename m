From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 17 Jul 2017 21:59:01 -0700
Message-ID: <596D9595.1010704@gmail.com>
References: <20170718110927.0f9974f6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170718110927.0f9974f6@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/17/2017 06:09 PM, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net-next tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> net/core/filter.o: In function `xdp_do_flush_map':
> filter.c:(.text+0x3770): undefined reference to `__dev_map_flush'
> net/core/filter.o: In function `__bpf_tx_xdp':
> filter.c:(.text+0x56dc): undefined reference to `__dev_map_insert_ctx'
> net/core/filter.o: In function `xdp_do_redirect_map':
> filter.c:(.text+0x5e24): undefined reference to `__dev_map_lookup_elem'
> 
> Caused by commit
> 
>   11393cc9b9be ("xdp: Add batching support to redirect map")
> 
> This build has
> 
> CONFIG_BPF=y
> # CONFIG_BPF_SYSCALL is not set
> 
> I have used the net-next tree from next-20170717 for today.
> 

I missed testing without CONFIG_BPF_SYSCALL. Patch is posted to netdev
and on patchworks at,

https://patchwork.ozlabs.org/patch/789862/

Thanks,
John
