From: Ashwanth Goli <ashwanth@codeaurora.org>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Tue, 13 Jun 2017 17:01:52 +0530
Message-ID: <cce358b0a2e9861141b0dfdac6b84859@codeaurora.org>
References: <20170613210845.24115319@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170613210845.24115319@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 2017-06-13 16:38, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net tree, today's linux-next build (powerpc
> ppc44x_defconfig) produced this warning:
> 
> net/core/dev.c: In function 'dev_cpu_dead':
> net/core/dev.c:8330:2: warning: 'remsd' is used uninitialized in this
> function [-Wuninitialized]
>   net_rps_send_ipi(remsd);
>   ^
> 
> Introduced by commit
> 
>   773fc8f6e8d6 ("net: rps: send out pending IPI's on CPU hotplug")
> 
> These builds have CONFIG_RPS not set.

I have sent the fix patch to netdev mailing list.
