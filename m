From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/16] isdn: hisax/elsa: fix sleep_on race in elsa FSM
Date: Wed, 26 Feb 2014 16:08:40 -0500 (EST)
Message-ID: <20140226.160840.2252241966959740296.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-14-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-14-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:53 +0100

> The state machine code in the elsa driver uses interruptible_sleep_on
> to wait for state changes, which is racy. A closer look at the possible
> states reveals that it is always used to wait for getting back into
> ARCOFI_NOP, so we can use wait_event_interruptible instead.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
