From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next V3 2/3] xen-netfront: split event
 channels support for Xen frontend driver
Date: Thu, 23 May 2013 14:46:18 +0100
Message-ID: <20130523134618.GA18648@zion.uk.xensource.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com>
 <1369240487-18834-3-git-send-email-wei.liu2@citrix.com>
 <519D1D61.8030500@oracle.com>
 <CAOsiSVXptBRRA=m3HFnO7eQWjxN_wgfzAcvw+rPebOPH9mRjXg@mail.gmail.com>
 <519D2C02.7080500@oracle.com>
 <CAOsiSVUHqezpo4u+Go1pm4vm7Hots2gDUJ9YEzVK7_FPSc3zLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: annie li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	jbeulich <jbeulich@suse.com>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29260 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758671Ab3EWNqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 09:46:20 -0400
Content-Disposition: inline
In-Reply-To: <CAOsiSVUHqezpo4u+Go1pm4vm7Hots2gDUJ9YEzVK7_FPSc3zLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 09:38:20PM +0100, Wei Liu wrote:
> On Wed, May 22, 2013 at 9:35 PM, annie li <annie.li@oracle.com> wrote:
> >
> > On 2013-5-22 16:20, Wei Liu wrote:
> >>
> >> On Wed, May 22, 2013 at 8:32 PM, annie li <annie.li@oracle.com> wrote:
> >>>
> >>>
> >>> Originally, netfront protects access to rx shared-ring with tx_lock, you
> >>> remove this protection here. It is better to protect the ring access by a
> >>> sperate rx_lock then.
> >>>
> >> TX ring and RX ring are separate rings. I don't think that comment / code
> >> makes sense any more. My stress test confirms that.
> >
> >
> > Yes, they are separate rings. Actually I am not sure why
> > RING_HAS_UNCONSUMED_RESPONSES(&np->rx) is protected by any tx_lock
> > originally. But for xennet_rx_interrupt, it is better to use rx_lock to
> > protect RING_HAS_UNCONSUMED_RESPONSES(&np->rx).
> >
> 
> This doesn't make sense to me either. Xen ring protocol is designed to
> be lock-free.
> And in netfront's case there is no concurrent access to the ring.
> 
> 

Annie, did I answer your questions / relieve your concern?


Wei.
