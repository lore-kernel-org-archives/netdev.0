From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Mon, 9 Sep 2013 10:20:11 +0100
Message-ID: <20130909092011.GM14104@zion.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
 <20130903215328.GA13465@zion.uk.xensource.com>
 <52271DFF.3070008@citrix.com>
 <1378298485.17510.109.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26374 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab3IIJUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Sep 2013 05:20:13 -0400
Content-Disposition: inline
In-Reply-To: <1378298485.17510.109.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 01:41:25PM +0100, Ian Campbell wrote:
[...]
> > > This bug was discussed back in July among Annie, Matt, Ian and I. We
> > > finally agreed to take Matt's solution. Matt agreed to post final
> > > version within a week but obviously he's too busy to do so. I was away
> > > so I didn't follow closely. Eventually it fell through the crack. :-(
> > 
> > I think I prefer fixing the counting for backporting to stable kernels.
> 
> That's a good argument. I think we should take this patch, or something
> very like it, now and then rebase the more complex thing on top.
> 

I take this as sort-of-ack by the maintainer.

David, please go ahead with your fix. I will post the other approach as
an improvement later on.

Wei.

> >  Xi's approach of packing the ring differently is a change in frontend
> > visible behaviour and seems more risky. e.g., possible performance
> > impact so I would like to see some performance analysis of that approach.
> 
> Yes.
