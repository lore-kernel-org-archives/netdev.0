From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Fri, 27 Jun 2008 02:09:55 -0400
Message-ID: <48648433.6070200@garzik.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080531225442.GA2747@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemm
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41255 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758135AbYF0GKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:10:01 -0400
In-Reply-To: <20080531225442.GA2747@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> 
> We currently don't signal the kernel we that this device can wake
> the system.  Call device_init_wakeup() to correct this.
> Without this device_can_wakeup and device_may_wakeup will return
> incorrect values.
> Together with the minimized acpi wakeup patch (6/4 ;)), which will
> follow in the next mail, this really makes wake-on-lan work for me
> as expected (i.e. "ethtool -s eth0 wol g" is sufficient, no
> additional magic needed).
> 
> Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

applied 5-6


