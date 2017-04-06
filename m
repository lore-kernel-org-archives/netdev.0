From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net: netfilter: Remove multiple assignment.
Date: Thu, 6 Apr 2017 21:35:16 +0200
Message-ID: <20170406193516.GA4743@salvia>
References: <20170327223326.GA486@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170327223326.GA486@arushi-HP-Pavilion-Notebook>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arushi,

On Tue, Mar 28, 2017 at 04:03:27AM +0530, Arushi Singhal wrote:
> This patch removes multiple assignments to follow the kernel coding
> style as also reported by checkpatch.pl.
> Done using coccinelle.
> @@
> identifier i1,i2;
> constant c;
> @@
> - i1=i2=c;
> + i1=c;
> + i2=i1;

I see more multiple assignments like this under:

net/netfilter/
net/ipv4/netfilter/
net/ipv6/netfilter/
net/bridge/netfilter/

So I would prefer whether fix them all or none.

Thanks!
