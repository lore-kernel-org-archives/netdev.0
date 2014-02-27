From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] atm: nicstar: remove interruptible_sleep_on_timeout
Date: Thu, 27 Feb 2014 15:23:08 -0500 (EST)
Message-ID: <20140227.152308.974173030016192682.davem@davemloft.net>
References: <1393412516-3762435-11-git-send-email-arnd@arndb.de>
	<20140226.110603.1107468127601575254.davem@davemloft.net>
	<201402271951.54970.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201402271951.54970.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 27 Feb 2014 19:51:54 +0100

> We are trying to finally kill off interruptible_sleep_on_timeout.
> the two uses in the nicstar driver can be trivially replaced
> with wait_event_interruptible_lock_irq_timeout, which prevents the
> wake-up race and is able to check the buffer state with scq->lock
> held.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied, thanks.
