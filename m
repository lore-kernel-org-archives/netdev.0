From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 17/18] 3c59x: fix duplex configuration
Date: Tue, 14 Aug 2007 01:38:45 -0400
Message-ID: <46C13FE5.8020509@garzik.org>
References: <200708102105.l7AL5Q2h008995@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org, protasnb@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44552 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935892AbXHNFir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:38:47 -0400
In-Reply-To: <200708102105.l7AL5Q2h008995@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> 
> A special sequence of ifconfig up/down and plug/unplug the cable can break
> the duplex configuration of the driver.
> 
> Setting
> vp->mii.full_duplex = vp->full_duplex
> in vortex_up should fix this.
> 
> Addresses Bug 8575 3c59x duplex configuration broken
> http://bugzilla.kernel.org/show_bug.cgi?id=8575
> 
> Cc: Martin Buck <mb-tmp-ohtmvyyn.xreary.bet@gromit.dyndns.org>
> Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> Cc: Natalie Protasevich <protasnb@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c59x.c |    1 +
>  1 files changed, 1 insertion(+)

applied


