From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 1/6] invisible network devices
Date: Tue, 30 Jan 2007 10:08:18 +0000
Message-ID: <20070130100818.GC8548@infradead.org>
References: <20070129184707.885764375.midnight@suse.cz> <20070129102814.6385ad2d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41213 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965394AbXA3KIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 05:08:36 -0500
Content-Disposition: inline
In-Reply-To: <20070129102814.6385ad2d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 10:28:14AM -0800, Stephen Hemminger wrote:
> Maybe code would be cleaner if you just could do:
> 	register_netdevice(mydev);
> 
> 	cloak_netdevice(mydev);
> 
> 
> And cloak_netdevice() just removed the network device from the 
> name table.  I would rather keep it with a real ifindex and in the
> device list, so that if the interface is miss used or the device
> is referenced by other devices, we don't see unexpected surprises
> like oops.

I don't think first publishing it and then hiding it is a good idea,
but I agreed that it should at least have a valid ifindex.
