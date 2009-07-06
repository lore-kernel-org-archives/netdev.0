From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: tun/tap crashes if open() /dev/net/tun and then
 poll() it.
Date: Mon, 06 Jul 2009 13:08:41 -0700 (PDT)
Message-ID: <20090706.130841.109675901.davem@davemloft.net>
References: <20090706001114.2d4517be@mako-desktop>
	<20090706011230.GC15156@gondor.apana.org.au>
	<20090706074835.3fe641f0@mako-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	abacabadabacaba@gmail.com, maxk@qualcomm.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: m.kozlowski@tuxland.pl
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20090706074835.3fe641f0@mako-desktop>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Mon, 6 Jul 2009 07:48:35 +0200

> Fix NULL pointer dereference in tun_chr_pool() introduced by
> commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554 and triggered
> by this code:
> 
> 	int fd;
> 	struct pollfd pfd;
> 	fd = open("/dev/net/tun", O_RDWR);
> 	pfd.fd = fd;
> 	pfd.events = POLLIN | POLLOUT;
> 	poll(&pfd, 1, 0);
> 
> Reported-by: Eugene Kapun <abacabadabacaba@gmail.com>
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Applied, thanks!
