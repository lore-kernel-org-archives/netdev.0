From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Mon, 2 Jul 2007 21:16:36 +0100
Message-ID: <20070702201636.GA5100@infradead.org>
References: <4688F512.3030801@garzik.org> <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51035 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbXGBUQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 16:16:54 -0400
Content-Disposition: inline
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 12:00:29PM -0700, Veeraiyan, Ayyappan wrote:
> Agreed. 
> Fake netdevs are needed for doing the multiple Rx queues in NAPI mode.
> We are thinking to solve in 2 ways. Having netdev pointer in ring
> structure or having an array of netdev pointers in ixgbe_adatper struct
> which would be visible to all rings.

Didn't we have a patchset floating around recently that separates NAPI
state from struct netdevice?

