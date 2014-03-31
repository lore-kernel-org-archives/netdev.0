From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Mar 31 (netfilter)
Date: Mon, 31 Mar 2014 08:49:24 -0700
Message-ID: <53398E84.4050907@infradead.org>
References: <20140331190618.ecee9947ade030d7fced05b9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140331190618.ecee9947ade030d7fced05b9@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/31/2014 01:06 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add material intended for v3.16 to your linux-next included
> branches until after v3.15-rc1 is released.
> 
> This tree still fails (more than usual) the powerpc allyesconfig build.
> 
> Changes since 20140328:
> 

on i386:
CONFIG_IPV6=m


net/built-in.o: In function `tproxy_tg6_v1':
xt_TPROXY.c:(.text+0xb2719): undefined reference to `udp6_lib_lookup'
xt_TPROXY.c:(.text+0xb2d0e): undefined reference to `udp6_lib_lookup'
xt_TPROXY.c:(.text+0xb2f61): undefined reference to `udp6_lib_lookup'
net/built-in.o: In function `tproxy_tg_init':
xt_TPROXY.c:(.init.text+0x28ba): undefined reference to `nf_defrag_ipv6_enable'



-- 
~Randy
