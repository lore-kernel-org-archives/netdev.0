From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/16] isdn: pcbit: fix interruptible_sleep_on race
Date: Wed, 26 Feb 2014 16:08:34 -0500 (EST)
Message-ID: <20140226.160834.847804163386929425.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-13-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-13-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:52 +0100

> interruptible_sleep_on is racy and going away. In case of pcbit,
> the driver would run into a timeout if the card is initialized
> before we start waiting for it. This uses wait_event to fix the
> race. In order to do this, the state machine handling for the
> timeout case has to get trivially reorganized so we actually know
> whether the timeout has occorred or not.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
