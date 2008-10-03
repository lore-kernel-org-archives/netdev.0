From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Fix recent WOL regression
Date: Fri, 3 Oct 2008 09:02:43 +0200
Message-ID: <20081003090243.724cf79c@speedy>
References: <200810022339.34025.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	Tino Keitel <tino.keitel@gmx.de>, netdev@vger.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35690 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbYJCHCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2008 03:02:50 -0400
In-Reply-To: <200810022339.34025.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 23:39:33 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> sky2: Fix recent WOL regression
> 
> Since dev->power.should_wakeup bit is used by the PCI core to
> decide whether the device should wake up the system from sleep
> states, set/unset this bit whenever WOL is enabled/disabled using
> sky2_set_wol() (this fixes a regression from 2.6.26 on the Tino's
> machine).
> 
> Remove an open-coded reference to the standard PCI PM registers that
> is not used any more.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Reported-by: Tino Keitel <tino.keitel@gmx.de>
> ---

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks for fixing this.
