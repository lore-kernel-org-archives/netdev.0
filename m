From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] Fix copper/fiber auto-selection for 88e1111
Date: Tue, 22 Jul 2008 18:02:40 -0400
Message-ID: <48865900.4060808@garzik.org>
References: <487DFBA9.8070400@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexandr Smirnov <asmirnov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Wang Jian <lark@linux.net.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53276 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYGVWCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 18:02:44 -0400
In-Reply-To: <487DFBA9.8070400@linux.net.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Jian wrote:
> The 27.15 bit (MII_M1111_HWCFG_FIBER_COPPER_AUTO) is disable bit. When
> set to 1, copper/fiber auto selection is disabled. The current code
> to enable but actually disable auto selection.
> 
> Signed-off-by: Wang Jian <lark@linux.net.cn>
> ---
>  drivers/net/phy/marvell.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied 1-2 manually -- both patches were corrupted and not apply-able 
using the standard git-am tool.


