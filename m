From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Sep 5 (netfilter: xt_socket.c)
Date: Thu, 05 Sep 2013 10:37:04 -0700
Message-ID: <5228C140.1010504@infradead.org>
References: <20130905193249.8b7c57afd5e39349ff5508bb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130905193249.8b7c57afd5e39349ff5508bb@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/13 02:32, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add any code for v3.13 to your linux-next included branches
> until after v3.12-rc1 is released.
> 
> Changes since 20130904:
> 

on x86_64:

when CONFIG_IPV6=m
and CONFIG_NETFILTER_XT_MATCH_SOCKET=y:

net/built-in.o: In function `socket_mt6_v1_v2':
xt_socket.c:(.text+0x51b55): undefined reference to `udp6_lib_lookup'
net/built-in.o: In function `socket_mt_init':
xt_socket.c:(.init.text+0x1ef8): undefined reference to `nf_defrag_ipv6_enable'



-- 
~Randy
