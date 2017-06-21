From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] tcp: md5: hide unused variable
Date: Wed, 21 Jun 2017 11:20:00 -0400 (EDT)
Message-ID: <20170621.112000.1689554856831469695.davem@davemloft.net>
References: <20170620201203.121119-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, colona@arista.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620201203.121119-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 20 Jun 2017 22:11:21 +0200

> Changing from a memcpy to per-member comparison left the
> size variable unused:
> 
> net/ipv4/tcp_ipv4.c: In function 'tcp_md5_do_lookup':
> net/ipv4/tcp_ipv4.c:910:15: error: unused variable 'size' [-Werror=unused-variable]
> 
> This does not show up when CONFIG_IPV6 is enabled, but the
> variable can be removed either way, along with the now unused
> assignment.
> 
> Fixes: 6797318e623d ("tcp: md5: add an address prefix for key lookup")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
