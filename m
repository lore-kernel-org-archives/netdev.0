From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] ip_tunnel: fix building with NET_IP_TUNNEL=m
Date: Thu, 12 Oct 2017 12:21:24 -0700 (PDT)
Message-ID: <20171012.122124.1754692727996077252.davem@davemloft.net>
References: <20171011135546.3536829-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011135546.3536829-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Oct 2017 15:55:31 +0200

> When af_mpls is built-in but the tunnel support is a module,
> we get a link failure:
> 
> net/mpls/af_mpls.o: In function `mpls_init':
> af_mpls.c:(.init.text+0xdc): undefined reference to `ip_tunnel_encap_add_ops'
> 
> This adds a Kconfig statement to prevent the broken
> configuration and force mpls to be a module as well in
> this case.
> 
> Fixes: bdc476413dcd ("ip_tunnel: add mpls over gre support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
