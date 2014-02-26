From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/16] isdn: divert, hysdn: fix interruptible_sleep_on
 race
Date: Wed, 26 Feb 2014 16:08:46 -0500 (EST)
Message-ID: <20140226.160846.1904753935237205820.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-15-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-15-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:54 +0100

> These two drivers use identical code for their procfs status
> file handling, which contains a small race against status
> data becoming available while reading the file.
> 
> This uses wait_event_interruptible instead to fix this
> particular race and eventually get rid of all sleep_on
> instances. There seems to be another race involving
> multiple concurrent readers of the same procfs file, which
> I don't try to fix here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
