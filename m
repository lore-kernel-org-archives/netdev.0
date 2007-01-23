From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4] atl1: Attansic L1 ethernet driver
Date: Tue, 23 Jan 2007 00:57:41 -0500
Message-ID: <45B5A3D5.6020508@garzik.org>
References: <20070121210416.GA2702@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, csnook@redhat.com, hch@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45454 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933020AbXAWF5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:57:50 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20070121210416.GA2702@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> This is the latest submittal of the patchset providing support for the 
> Attansic L1 gigabit ethernet adapter.  This patchset is built against 
> kernel version 2.6.20-rc5.
> 
> This version incorporates all comments from:
> 
> Christoph Hellwig:
> http://lkml.org/lkml/2007/1/11/43
> http://lkml.org/lkml/2007/1/11/45
> http://lkml.org/lkml/2007/1/11/48
> http://lkml.org/lkml/2007/1/11/49
> 
> Jeff Garzik:
> http://lkml.org/lkml/2007/1/18/233
> 
> Many thanks to both for reviewing the driver.
> 
> The monolithic version of this patchset may be found at:
> ftp://hogchain.net/pub/linux/attansic/kernel_driver/atl1-2.0.5-linux-2.6.20.rc5.patch.bz2

OK, I have merged the monolithic patch into jgarzik/netdev-2.6.git#atl1. 
  Once I'm done merging patches tonight, I will merge this new 'atl1' 
branch into the 'ALL' meta-branch, which will auto-propagate this driver 
into Andrew Morton's -mm for testing.

For future driver updates, please send a patch rather than the full 
driver diff.

If it looks good, we will push for 2.6.21 (or 2.6.22, if updates or 
objections continue to come fast and furious).  It's in "the system" 
now, thanks for all your hard work!

	Jeff



