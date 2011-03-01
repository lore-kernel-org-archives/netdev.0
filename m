From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] ipx: remove the BKL
Date: Tue, 01 Mar 2011 15:15:48 -0800 (PST)
Message-ID: <20110301.151548.116374357.davem@davemloft.net>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de>
	<1299021191-17961-8-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299021191-17961-8-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  2 Mar 2011 00:13:11 +0100

> This replaces all instances of lock_kernel in the
> IPX code with lock_sock. As far as I can tell, this
> is safe to do, because there is no global state
> that needs to be locked in IPX, and the code does
> not recursively take the lock or sleep indefinitely
> while holding it.
> 
> Compile-tested only.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David S. Miller <davem@davemloft.net>
