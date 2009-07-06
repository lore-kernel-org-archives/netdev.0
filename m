From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [dm-devel] Updated cluster log patch (take 5)
Date: Mon, 6 Jul 2009 07:42:17 -0400
Message-ID: <20090706114217.GA1679@infradead.org>
References: <1244845317.19994.3.camel@hydrogen.msp.redhat.com> <20090613110733.GA7895@infradead.org> <20090620120128.GB22786@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christoph Hellwig <hch@infradead.org>,
	device-mapper development <dm-devel@redhat.com>,
	netdev@vger.kernel.org, Jonathan Brassow <jbrassow@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41874 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbZGFLmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 07:42:14 -0400
Content-Disposition: inline
In-Reply-To: <20090620120128.GB22786@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2009 at 08:01:29AM -0400, Thomas Graf wrote:
> > Maye I misremember it, but isn't the connector code strongly deprecated
> > in favour of genetlink?
> 
> Use of connector is deprecated, it does not have any advantages over
> genetlink while genetlink provides an optional attributes based
> protocol interface which allows for messaging protocols to be developed
> which can be extended without breaking binary compatibility. It also
> features a userspace library which makes development trivial.
> 
> 
> I guess nobody will force you but use of genetlink is encouraged.

Jonathan, I think it's really sad that this got pushed into mainline
after the merge window without even replying to this statement of one
of our core networking developers.

