From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: fix IPV6=n build
Date: Tue, 17 Jun 2008 16:16:22 -0700 (PDT)
Message-ID: <20080617.161622.33390338.davem@davemloft.net>
References: <20080617094214.c8cc2ce2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	linux-next@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080617094214.c8cc2ce2.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 17 Jun 2008 09:42:14 -0700

> Fix bridge netfilter code so that it uses CONFIG_IPV6 as needed:
> 
> net/built-in.o: In function `ebt_filter_ip6':
> ebt_ip6.c:(.text+0x87c37): undefined reference to `ipv6_skip_exthdr'
> net/built-in.o: In function `ebt_log_packet':
> ebt_log.c:(.text+0x88dee): undefined reference to `ipv6_skip_exthdr'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
