From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/26] atl1: divide and modernize
Date: Tue, 1 Jan 2008 17:58:40 +0000
Message-ID: <20080101175839.GA25201@infradead.org>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36993 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbYAAR6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 12:58:42 -0500
Content-Disposition: inline
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 08:22:27PM -0600, Jay Cliburn wrote:
> 
> [Neglected to cc netdev in the first wave.]
> 
> Hello Jeff,
> 
> Happy New Year to you and all.
> 
> In preparation for a future atl2 driver for the Atheros L2 10/100 chip,
> we propose to move the existing atl1 driver to a new directory
> (drivers/net/atlx), then split out functions and definitions that both
> atl1 and atl2 can share.  The final structure will look like this:
> 
> directory or file		status
> =======================		==========================
> drivers/net/atl1/		deleted
> drivers/net/atlx/		new
> drivers/net/atlx/atl1.c		atl1-specific functions
> drivers/net/atlx/atl1.h		atl1-specific definitions
> drivers/net/atlx/atlx.c		atl1-atl2 shared functions
> drivers/net/atlx/atlx.h		atl1-atl2 shared definitions
> 
> The first two patches submitted in this patchset accomplish the relocation
> by movng the atl1 driver -- lock, stock, and barrel -- over to
> drivers/net/atlx, then splitting out shareable functions and definitions.
> Some transitory hackery will be present until the atl2 merge.  Please
> overlook it for now.
> 
> The remaining 24 patches bring the atl1 driver up to par with the current
> vendor driver version 1.2.40.2.  NAPI support is included and it seems
> to work, but it needs to be scrutinized by an experienced eye.  I had a
> hard time finding much current NAPI documentation, so I just hacked at
> it by looking at the e1000 driver.

How much shared code is going to be there in the end?  Unless it's a lot
I fear that the maintaince burden far outweights the benefit of having
shared code.

