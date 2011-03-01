From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] appletalk: remove the BKL
Date: Tue, 01 Mar 2011 15:15:30 -0800 (PST)
Message-ID: <20110301.151530.242137036.davem@davemloft.net>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de>
	<1299021191-17961-7-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299021191-17961-7-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  2 Mar 2011 00:13:10 +0100

> This changes appletalk to use lock_sock instead of
> lock_kernel for serialization. I tried to make sure
> that we don't hold the socket lock during sleeping
> functions, but I did not try to prove whether the
> locks are necessary in the first place.
> 
> Compile-tested only.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David S. Miller <davem@davemloft.net>
