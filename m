From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 22:43:41 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5256B1EB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	"Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>, <shemminger@osdl.org>,
	<mchan@broadcom.com>, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42086 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S932201AbWHHFn7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 01:43:59 -0400
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca]
> On Mon, 2006-07-08 at 13:53 -0700, Brandeburg, Jesse wrote:
> 
> > we don't enable it right now, but you could use the TXQE (tx queue
> empty)
> > interrupt to avoid the starvation case.  I think it might flood you
with
> > TXQE interrupts however, so we'd probably have to figure out some
way to
> > turn it on occasionally.
> >
> 
> I think it may make sense to set on netif_stop and reset on wake. I
take
> it "empty" means all the descriptors for sending are gone?

We can try it.  Empty means that the adapter has completed all transmit
work and has no more to do (register TDH == TDT)

Jesse
