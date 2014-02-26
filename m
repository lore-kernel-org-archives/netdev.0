From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] atm: firestream: fix interruptible_sleep_on race
Date: Wed, 26 Feb 2014 16:08:26 -0500 (EST)
Message-ID: <20140226.160826.1051230037229837227.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-12-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-12-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:51 +0100

> interruptible_sleep_on is racy and going away. This replaces the one use
> in the firestream driver with the appropriate wait_event_interruptible
> variant.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied.
