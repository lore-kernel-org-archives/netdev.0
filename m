From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 19 Jun 2008 05:11:35 -0400
Message-ID: <20080619091135.GA11101@infradead.org>
References: <20080619062701.46a98ab1@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>, jeff@garzik.org,
	netdev@vger.kernel.org, sathyap@serverengines.com
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:57415 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbYFSJLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 05:11:38 -0400
Content-Disposition: inline
In-Reply-To: <20080619062701.46a98ab1@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 11:27:01PM -0700, Subbu Seetharaman wrote:
> We could not get KBUILD_EXTRA_SYMBOLS to work.
> This  is what we did :
> 
> beclib's Module.symvers has entries like this :
> 
> 0x00000000      be_eq_destroy   /home/subbu/kod39-sperla/drivers/message/beclib/beclib  EXPORT_SYMBOL 
> 
> benet uses exports from beclib and we have the following line in benet's Makefile: 
> KBUILD_EXTRA_SYMBOLS = $(src)/../../message/beclib/Module.symvers 
> 
> When we build benet we still get warnings like this
> for symbols defined and exported from beclib :
> WARNING: "be_eq_destroy" [/home/subbu/kod39-sperla/drivers/net/benet/benet.ko] undefined! 
> 


The righ answer is of course to kill all this beclib junk and write
a proper linux driver.  We're made it pretty clear a few times in the
past that these abstraction layers don't go in.

