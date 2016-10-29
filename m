From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] net: ip, diag: include net/inet_sock.h
Date: Sat, 29 Oct 2016 14:53:09 -0400 (EDT)
Message-ID: <20161029.145309.2094094755177056753.davem@davemloft.net>
References: <20161025155339.9892-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, gorcunov@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161025155339.9892-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Oct 2016 17:53:22 +0200

> The newly added raw_diag.c fails to build in some configurations
> unless we include this header:
> 
> In file included from net/ipv4/raw_diag.c:6:0:
> include/net/raw.h:71:21: error: field 'inet' has incomplete type
> net/ipv4/raw_diag.c: In function 'raw_diag_dump':
> net/ipv4/raw_diag.c:166:29: error: implicit declaration of function 'inet_sk'
> 
> Fixes: 432490f9d455 ("net: ip, diag -- Add diag interface for raw sockets")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
