From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 8/8] bonding: Add "follow" option to fail_over_mac
Date: Thu, 22 May 2008 07:09:19 -0400
Message-ID: <4835545F.1080206@pobox.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com> <12110838151824-git-send-email-fubar@us.ibm.com> <12110838151104-git-send-email-fubar@us.ibm.com> <12110838162313-git-send-email-fubar@us.ibm.com> <1211083816660-git-send-email-fubar@us.ibm.com> <1211083817934-git-send-email-fubar@us.ibm.com> <1211083818228-git-send-email-fubar@us.ibm.com> <12110838181126-git-send-email-fubar@us.ibm.com> <12110838193155-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48270 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762106AbYEVLJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:09:21 -0400
In-Reply-To: <12110838193155-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Add a "follow" selection for fail_over_mac.  This option
> causes the MAC address to move from slave to slave as the active
> slave changes.  This is in addition to the existing fail_over_mac option
> that causes the bond's MAC address to change during failover.
> 
> 	This new option is useful for devices that cannot tolerate
> multiple ports using the same MAC address simultaneously, either
> because it confuses them or incurs a performance penalty (as is the
> case with some LPAR-aware multiport devices).  Because the MAC of the
> bond itself does not change, the "follow" option is slightly more
> reliable during failover and doesn't change the MAC of the bond during
> operation.
> 
> 	This patch requires a previous ARP monitor change to properly
> handle RTNL during failovers.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  Documentation/networking/bonding.txt |   96 ++++++++++++------
>  drivers/net/bonding/bond_main.c      |  185 ++++++++++++++++++++++++++-------
>  drivers/net/bonding/bond_sysfs.c     |   36 +++----
>  drivers/net/bonding/bonding.h        |    4 +
>  4 files changed, 232 insertions(+), 89 deletions(-)

applied 1-8


