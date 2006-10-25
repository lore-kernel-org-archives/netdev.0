From: Jeff Garzik <jeff@garzik.org>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 22:47:18 -0400
Message-ID: <20061025024718.GB23769@havoc.gtf.org>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:11490 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1161204AbWJYCrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 22:47:19 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <453ECB2C.3070202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 07:25:48PM -0700, Ben Greear wrote:
> From reading the Documentation/filesystems/sysfs.txt, it seems like
> it is not recommended that one use sysfs for anything other than
> very simple (and single) attributes.
> 
> If you know of a piece of code that actually passes back a struct or
> other binary blob of data, please point me to it so I can learn from it.

Please grep for sysfs_create_bin_file, you will find plenty of examples.

	Jeff



