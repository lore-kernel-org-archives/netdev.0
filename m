From: "cramerj" <cramerj@intel.com>
Subject: RE: Patch: Asynchronous IPI and e1000 Multiple Queues (aka ReceiveSide Scaling)
Date: Fri, 18 Aug 2006 13:50:20 -0700
Message-ID: <F2C59D1E488E7A4FB7F6F673DAF832590179FED7@orsmsx413.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"Subhachandra Chandra" <schandra@bluelane.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41327 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S964786AbWHRUub convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 16:50:31 -0400
Content-class: urn:content-classes:message
To: <piet@bluelane.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davem brought up the point of how expensive IPIs are.  Our own
performance tests for multi-queue weren't all that impressive...which
just proved his point.  So we decided not to go forward with the patch.
Really, the hardware we coded multi-queue for was not ready for such a
feature.  Hardware that supports MSI-X is really what makes sense for
multi-queue.  Since the 8257x hardware was the first family to support
multi-queue, all previous hardware generations (PCI or PCI-X) would not
have benefited from that patch.

Thanks,
-Jeb

> -----Original Message-----
> From: Piet Delaney [mailto:piet@bluelane.com]
> Sent: Wednesday, August 16, 2006 6:41 PM
> To: cramerj; netdev@vger.kernel.org
> Cc: Piet Delaney; David Miller; Stephen Hemminger; Subhachandra
Chandra
> Subject: Re: Patch: Asynchronous IPI and e1000 Multiple Queues (aka
> ReceiveSide Scaling)
> 
> On Wed, 2006-08-16 at 18:33 -0700, Piet Delaney wrote:
> > I came across your Sept 2005 LKML and NetDev posting:
> >
> > 	http://lwn.net/Articles/152989/
> >
> > and was wondering what's been going on with this
> > since your posting. Looks like an interesting
> > patch that may be useful in our environment.
> 
> I just noticed this is for PCI-Express. Has anything
> similar been done for PCI-X?
> 
> -piet
> 
> >
> > -piet
> >
> --
> Piet Delaney
> BlueLane Teck
> W: (408) 200-5256; piet@bluelane.com
> H: (408) 243-8872; piet@piet.net
