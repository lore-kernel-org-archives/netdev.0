From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 12:03:50 +0000
Message-ID: <20071122120350.GA5378@infradead.org>
References: <20071122343.446909000@suse.de> <20071122110622.GB4552@infradead.org> <200711221254.50256.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org,
	rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54327 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbXKVMDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 07:03:52 -0500
Content-Disposition: inline
In-Reply-To: <200711221254.50256.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 12:54:49PM +0100, Andi Kleen wrote:
> On Thursday 22 November 2007 12:06, Christoph Hellwig wrote:
> > Very nice, looking forward to organize the exports mess a bit more.
> 
> I would need people to help me converting more subsystems to this new scheme.
> 
> In particular all exports that are only used by a single module are direct 
> candidates for a namespace. For the others it has to be checked by someone
> who knows the particular subsystem well.
> 
> e.g. for SCSI it would be nice to put the symbols only used by sd/sr/sg etc.
> into a namespace.

True.  I'll take care of the scsi bits once this goes in.
