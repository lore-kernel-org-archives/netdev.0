From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/16] isdn: fix multiple sleep_on races
Date: Wed, 26 Feb 2014 16:08:52 -0500 (EST)
Message-ID: <20140226.160852.1312618438946802150.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-16-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-16-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:55 +0100

> The isdn core code uses a couple of wait queues with
> interruptible_sleep_on, which is racy and about to get
> removed from the kernel. Fortunately, we know for each case
> what we are waiting for, so they can all be converted to
> the better wait_event_interruptible interface.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
