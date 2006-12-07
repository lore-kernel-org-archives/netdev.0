From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] netxen: sparse warning and ioctl bug fixes
Date: Thu, 7 Dec 2006 10:09:03 +0000
Message-ID: <20061207100903.GA27904@infradead.org>
References: <20061205120717.2e362ddf@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Amit S. Kale" <amitkale@netxen.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39589 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031929AbWLGKJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 05:09:14 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061205120717.2e362ddf@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 05, 2006 at 12:07:17PM -0800, Stephen Hemminger wrote:
> Fix sparse warnings and get rid of casts that hide misuse
> of __user pointers.  There were two real bugs here:
>   * ioctl was copying uninitialized stack om NETXEN_NIC_NAME
>   * ioctl was dereferencing a user pointer
>     in nettxen_nic_cmd_clear_stats.
> 
> IMHO the ioctl usage in this driver is going to be more maintenance
> burden than useful. and should be removed.

Yes, please send a patch to kill the ioctls.  Given all the other mess
in the driver I really wonder who ACKed it going in.

