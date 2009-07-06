From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [dm-devel] Updated cluster log patch (take 5)
Date: Mon, 6 Jul 2009 16:19:02 +0400
Message-ID: <20090706121902.GA5660@ioremap.net>
References: <1244845317.19994.3.camel@hydrogen.msp.redhat.com> <20090613110733.GA7895@infradead.org> <20090620120128.GB22786@bombadil.infradead.org> <20090706114217.GA1679@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: device-mapper development <dm-devel@redhat.com>,
	netdev@vger.kernel.org, Jonathan Brassow <jbrassow@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:51764 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559AbZGFMTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 08:19:15 -0400
Content-Disposition: inline
In-Reply-To: <20090706114217.GA1679@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 07:42:17AM -0400, Christoph Hellwig (hch@infradead.org) wrote:
> On Sat, Jun 20, 2009 at 08:01:29AM -0400, Thomas Graf wrote:
> > > Maye I misremember it, but isn't the connector code strongly deprecated
> > > in favour of genetlink?
> > 
> > Use of connector is deprecated, it does not have any advantages over
> > genetlink while genetlink provides an optional attributes based
> > protocol interface which allows for messaging protocols to be developed
> > which can be extended without breaking binary compatibility. It also
> > features a userspace library which makes development trivial.
> > 
> > 
> > I guess nobody will force you but use of genetlink is encouraged.
> 
> Jonathan, I think it's really sad that this got pushed into mainline
> after the merge window without even replying to this statement of one
> of our core networking developers.

Apparently Christoph never tried neither connector nor genetlink.
Because the former has very different interface than the latter.
Genetlink was created for network developers who are familiar with
attribute lists (used long before both were created), skbs and inner
structure of the received packet. While connector has interface with a
single purpose of being a simple callback invocation for those who do
not want to dig into network land to get a message from the userspace.

As of talking about advantages of the inner structure of how both
operate please check the code, there is a fair number of things one can
do with one and another systems.

-- 
	Evgeniy Polyakov
