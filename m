From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 19 Jun 2008 06:01:51 -0400
Message-ID: <20080619100151.GA24434@infradead.org>
References: <20080619095919.cf02dbe3@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>, jeff@garzik.org,
	netdev@vger.kernel.org, sathyap@serverengines.com
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39148 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbYFSKBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:01:52 -0400
Content-Disposition: inline
In-Reply-To: <20080619095919.cf02dbe3@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2008 at 02:59:19AM -0700, Subbu Seetharaman wrote:
> Christoph,
> 
> The primary reason for separating the lower layer
> code from rest of the driver is to share it
> across two drivers for the two functions
> of the device.

Then please look at the various drivers that already do this.  Just
built each module on it's own without strange cross-directory builds.

> The secondary objective of
> keeping this code OS neutral through 
> abstractions has been conceded based
> on the review comments from the last few 
> rounds.

But that's not how the code looks like.  There's still tons and tons
of useless wrappers that just make the code unreadable.

