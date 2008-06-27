From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND PATCH 2/3] e1000: remove PCI Express device IDs
Date: Fri, 27 Jun 2008 02:08:14 -0400
Message-ID: <486483CE.8010305@garzik.org>
References: <20080622221916.5907.79563.stgit@localhost.localdomain> <20080622222021.5907.16668.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50240 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257AbYF0GIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:08:20 -0400
In-Reply-To: <20080622222021.5907.16668.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> We do not want to prolong the situation much longer that e1000
> and e1000e support these devices at the same time. As a result,
> take out the bandage that was added for the interim period
> and remove all the PCI Express device IDs from e1000.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> ---
> 
>  drivers/net/Kconfig            |    3 ---
>  drivers/net/e1000/e1000_main.c |   33 ---------------------------------
>  2 files changed, 0 insertions(+), 36 deletions(-)

applied to #upstream-next (queued for 2.6.27)

BIG FLASHING WARNING NOTE to x86 maintainers and others:

Make sure your defconfig changes are in place for this change.


