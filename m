From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v4 0/10] skb paged fragment destructors
Date: Tue, 10 Apr 2012 16:50:04 +0100
Message-ID: <1334073004.5394.59.camel@zakaz.uk.xensource.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <4F8455EE.8010709@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"David VomLehn" <dvomlehn@cisco.com>,
	xen-devel <xen-devel@lists.xen.org>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:63807 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759191Ab2DJPuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:50:06 -0400
In-Reply-To: <4F8455EE.8010709@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 16:46 +0100, Bart Van Assche wrote:
> On 04/10/12 14:26, Ian Campbell wrote:
> 
> > I think this is v4, but I've sort of lost count, sorry that it's taken
> > me so long to get back to this stuff.
> > 
> > The following series makes use of the skb fragment API (which is in 3.2
> > +) to add a per-paged-fragment destructor callback. This can be used by
> > creators of skbs who are interested in the lifecycle of the pages
> > included in that skb after they have handed it off to the network stack.
> 
> 
> Hello Ian,
> 
> Great to see v4 of this patch series. But which kernel version has this
> patch series been based on ? I've tried to apply this series on 3.4-rc2

It's based on net-next/master. Specifically commit de8856d2c11f.

Ian.
