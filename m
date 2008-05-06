From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] bonding: Do not call free_netdev for already registered
 device.
Date: Tue, 06 May 2008 12:17:29 -0400
Message-ID: <48208499.3000501@pobox.com>
References: <12097757801056-git-send-email-fubar@us.ibm.com> <12097757822222-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45255 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbYEFQRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:17:34 -0400
In-Reply-To: <12097757822222-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> 
> If the call to bond_create_sysfs_entry in bond_create fails, the
> proper rollback is to call unregister_netdevice, not free_netdev.
> Otherwise - kernel BUG at net/core/dev.c:4057!
> 
> Checked with artificial failures injected into bond_create_sysfs_entry.
> 
> Pavel's original patch modified by Jay Vosburgh to move code around
> for clarity (remove goto-hopping within the unwind block).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_main.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)

applied 1-4


