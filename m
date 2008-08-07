From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] bonding: refactor mii monitor
Date: Thu, 07 Aug 2008 04:00:17 -0400
Message-ID: <489AAB91.2000202@pobox.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com> <12150481241992-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59661 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbYHGIAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 04:00:21 -0400
In-Reply-To: <12150481241992-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Refactor mii monitor.  As with the previous ARP monitor refactor,
> the motivation for this is to handle locking rationally (in this case,
> removing conditional locking) and generally clean up the code.
> 
> 	This patch breaks up the monolithic mii monitor into two phases:
> an inspection phase, followed by an optional commit phase.  The commit phase
> is the only portion that requires RTNL or makes changes to state, and is
> only called when inspection finds something to change.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_3ad.c  |    1 +
>  drivers/net/bonding/bond_main.c |  394 +++++++++++++++++----------------------
>  2 files changed, 173 insertions(+), 222 deletions(-)

applied 1-5


