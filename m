From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: igb: Intel 82575 gigabit ethernet driver (take #3)
Date: Fri, 11 Jan 2008 09:17:28 +0000
Message-ID: <20080111091728.GB14910@infradead.org>
References: <4786AB0C.6010202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38296 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760706AbYAKJRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 04:17:33 -0500
Content-Disposition: inline
In-Reply-To: <4786AB0C.6010202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 03:32:28PM -0800, Kok, Auke wrote:
> - cleaned up largely against sparse, checkpatch

largely means not completely, right?  Please make sure there's no sparse
warnings left at least.  checkpatch is not that criticial, but it would
be good to have an explanation for everything left.


some comments on the patch

 - please remove that sill copyright heder on the Makefile, it's hard
   to claim any rights on a trivial 3 line makefile.
 - also please use igb-y instead of igb-objs in the Makefile
 - the driver would be a lot more readable (and more importantly
   hackable) if it was written in a natural flow instead of having dozends 
   of lines of forward declarations in every file.
 - so you're adding your own phy abstraction.  Is there a good reason
   you can't simply use the generic phylib?
