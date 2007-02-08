From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 8 Feb 2007 13:19:11 -0800
Message-ID: <20070208211911.GA20988@suse.de>
References: <adalkj8l6vb.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:38687 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423409AbXBHVUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 16:20:37 -0500
Content-Disposition: inline
In-Reply-To: <adalkj8l6vb.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 12:41:28PM -0800, Roland Dreier wrote:
> Commit 43cb76d9 ("Network: convert network devices to use struct
> device instead of class_device") breaks the just-merged cxgb3 driver,
> since the code that was merged predates the change and was not in the
> tree when Greg made the change.
> 
> This patch fixes cxgb3 to build with the change.  It also removes the
> private to_net_dev() macro and changes the use of bare netdev->priv in
> favor of netdev_priv(netdev) in the sysfs attribute functions.
> 
> I tested this on my system which has cxgb3 hardware, and it looks like
> all the sysfs files are created correctly and contain sane-looking
> values, although I don't actually know how to test that every
> attribute is working as it should.

If it compiles with no warnings, it should be safe.

> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

But I think Jeff already has a patch in the queue that makes this very
change :)

thanks,

greg k-h
