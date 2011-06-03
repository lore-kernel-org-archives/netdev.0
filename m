From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,02/13] tg3: Cleanup transmit error path
Date: Fri, 03 Jun 2011 00:02:03 -0700 (PDT)
Message-ID: <20110603.000203.2086668674972261966.davem@davemloft.net>
References: <1307053115.3656.19.camel@x201>
	<20110602230139.GD5068@mcarlson.broadcom.com>
	<1307063914.3656.22.camel@x201>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: alex.williamson@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab1FCHCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 03:02:08 -0400
In-Reply-To: <1307063914.3656.22.camel@x201>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@redhat.com>
Date: Thu, 02 Jun 2011 19:18:34 -0600

> On Thu, 2011-06-02 at 16:01 -0700, Matt Carlson wrote:
>> Does this patch fix the problem?
> 
> Yes it does, probably explains the subsequent iommu faults if that off
> by one unmapping sometimes finds a non-zero address to unmap.  Thanks,
> 
> Alex
> 
> Tested-by: Alex Williamson <alex.williamson@redhat.com>

Applied, thanks.
