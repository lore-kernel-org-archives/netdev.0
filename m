From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: fix net/core/sock.c build error
Date: Mon, 10 Sep 2012 16:45:13 -0400 (EDT)
Message-ID: <20120910.164513.400687476300645876.davem@davemloft.net>
References: <20120910172407.c5ad953c008165fcd862bd3c@canb.auug.org.au>
	<504E1193.4060809@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <504E1193.4060809@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 10 Sep 2012 09:13:07 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix net/core/sock.c build error when CONFIG_INET is not enabled:
> 
> net/built-in.o: In function `sock_edemux':
> (.text+0xd396): undefined reference to `inet_twsk_put'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied to 'net', thanks Randy.
