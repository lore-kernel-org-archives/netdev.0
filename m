From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Sep 4 (netfilter: xt_TPROXY)
Date: Wed, 04 Sep 2013 10:46:58 -0700
Message-ID: <52277212.5020006@infradead.org>
References: <20130904181300.06fbf0698863cfaacf9fad9a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130904181300.06fbf0698863cfaacf9fad9a@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/13 01:13, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add any code for v3.13 to your linux-next included branches
> until after v3.12-rc1 is released.
> 
> Changes since 20130902:
> 

on x86_64:

when CONFIG_IPV6=m
and CONFIG_NETFILTER_XT_TARGET_TPROXY=y:

net/built-in.o: In function `tproxy_tg6_v1':
xt_TPROXY.c:(.text+0x5dc05): undefined reference to `udp6_lib_lookup'
xt_TPROXY.c:(.text+0x5e32f): undefined reference to `udp6_lib_lookup'
xt_TPROXY.c:(.text+0x5e432): undefined reference to `udp6_lib_lookup'
net/built-in.o: In function `tproxy_tg_init':
xt_TPROXY.c:(.init.text+0x1540): undefined reference to `nf_defrag_ipv6_enable'


-- 
~Randy
