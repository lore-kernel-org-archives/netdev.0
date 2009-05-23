From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] net: remove COMPAT_NET_DEV_OPS
Date: Sat, 23 May 2009 12:55:31 -0400
Message-ID: <20090523165531.GA14081@infradead.org>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com> <20090523074143.445ef830@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55891 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbZEWQzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 12:55:31 -0400
Content-Disposition: inline
In-Reply-To: <20090523074143.445ef830@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 07:41:43AM -0700, Stephen Hemminger wrote:
> On Sat, 23 May 2009 18:17:39 +0400
> Alexander Beregalov <a.beregalov@gmail.com> wrote:
> 
> > All drivers are already converted to new net_device_ops API
> > and nobody uses old API anymore.
> > 
> > Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> 
> This go through the feature-removal-schedule process, to
> allow other drivers that live outside the tree some notice for change.

I don't think so.  We do tons of API changes and don't do such a process
around it.  Removal of the old pointers gives a clear compilation
breakage so it's not even dangerous.

