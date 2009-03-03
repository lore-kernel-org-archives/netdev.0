From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol
	identifer
Date: Tue, 3 Mar 2009 14:41:54 -0500
Message-ID: <20090303194154.GK1480@hmsreliant.think-freely.org>
References: <20090303170014.GB1480@hmsreliant.think-freely.org> <20090303182006.GB29236@ioremap.net> <20090303190054.GI1480@hmsreliant.think-freely.org> <20090303190457.GA8006@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40398 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbZCCTmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 14:42:03 -0500
Content-Disposition: inline
In-Reply-To: <20090303190457.GA8006@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 10:04:57PM +0300, Evgeniy Polyakov wrote:
> On Tue, Mar 03, 2009 at 02:00:54PM -0500, Neil Horman (nhorman@tuxdriver.com) wrote:
> > Because this is its own protocol.  I could have used NETLINK_GENERIC I suppose,
> > but this is a feature that, if used is going to be commonly built into the
> > kernel, I see no need to add an additional step of making userspace search for a
> > protocol registered to NETLINK_GENERIC when we dont need to.  In other words,
> > why not define my own protocol?
> 
> genetlink is alwats built into the kernel, there are access libraries
> helpers and there is really no userspace overhead. It was really
> specially designed for this kind of the tasks to eliminate netlink
> internal structure access and provide simple high-level interface.
> 
Not really about performance overhead in my view, its about programming
overhead.  Its just more work, and without any really tangible gain IMO.  Could
I use it?  Sure, but I don't really get any particular benefit out of doing so,
and from the kernel standpoint, it makes no difference either, except that its
one more header to parse before I get to my data.  I guess it just boils down to
choice for me
Neil

> -- 
> 	Evgeniy Polyakov
> 
