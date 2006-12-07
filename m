From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netxen: sparse warning and ioctl bug fixes
Date: Thu, 07 Dec 2006 05:00:11 -0500
Message-ID: <4577E62B.2080704@pobox.com>
References: <20061205120717.2e362ddf@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36146 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031941AbWLGKAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:00:16 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061205120717.2e362ddf@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix sparse warnings and get rid of casts that hide misuse
> of __user pointers.  There were two real bugs here:
>   * ioctl was copying uninitialized stack om NETXEN_NIC_NAME
>   * ioctl was dereferencing a user pointer
>     in nettxen_nic_cmd_clear_stats.
> 
> IMHO the ioctl usage in this driver is going to be more maintenance
> burden than useful. and should be removed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

ACK but netxen is in heavy flux right now, with upstream workqueue 
changes, changes from Amit, etc.  so, it didn't apply.

Ever considered submitting via git?  :)

	Jeff



