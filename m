From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: hide ip6_encap_hlen/ip6_tnl_encap definitions
Date: Sun, 29 May 2016 22:24:34 -0700 (PDT)
Message-ID: <20160529.222434.161537875469088214.davem@davemloft.net>
References: <1464187873-219087-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464187873-219087-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 May 2016 16:50:45 +0200

> A recent cleanup moved MAX_IPTUN_ENCAP_OPS along with some other
> definitions, but it is now invisible when CONFIG_INET is
> not defined, but still referenced from ip6_tunnel.h:
> 
> In file included from net/xfrm/xfrm_input.c:17:0:
> include/net/ip6_tunnel.h:67:17: error: 'MAX_IPTUN_ENCAP_OPS' undeclared here (not in a function)
>    ip6tun_encaps[MAX_IPTUN_ENCAP_OPS];
>                  ^~~~~~~~~~~~~~~~~~~
> 
> This hides the ip6_encap_hlen and ip6_tnl_encap functions inside
> of CONFIG_INET so we don't run into the the problem.
> 
> Alternatively we could move the macro out of the #ifdef again to
> restore the previous behavior
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 55c2bc143224 ("net: Cleanup encap items in ip_tunnels.h")

Applied.
