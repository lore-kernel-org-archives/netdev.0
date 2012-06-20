From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: next-20120620 build error in netfilter
Date: Wed, 20 Jun 2012 19:28:01 +0200
Message-ID: <20120620172801.GA9385@1984>
References: <32596.1340212473@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <32596.1340212473@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 20, 2012 at 01:14:33PM -0400, Valdis Kletnieks wrote:
> Today's linux-next fails to build with CONFIG_NF_NAT_NEEDED=y and CONFIG_NF_NAT=m
> 
>   LD      init/built-in.o
> net/built-in.o:(.data+0x4408): undefined reference to `nf_nat_tcp_seq_adjust'
> make: *** [vmlinux] Error 1

I guess you have NF_CT_NETLINK=y, right?

> Breakage introduced with this commit:
> 
> commit 8c88f87cb27ad09086940bdd3e6955e5325ec89a
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Thu Jun 7 13:31:25 2012 +0200
> 
>     netfilter: nfnetlink_queue: add NAT TCP sequence adjustment if packet mangled
> 
