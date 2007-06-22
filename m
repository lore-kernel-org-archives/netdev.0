From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 14:03:35 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179146@orsmsx414.amr.corp.intel.com>
References: <467C1A9F.5060004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57272 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbXFVVDv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 17:03:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467C1A9F.5060004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Patrick McHardy wrote:
> > Waskiewicz Jr, Peter P wrote:
> > 
> >>Thought about this more last night and this morning.  As 
> far as I can 
> >>tell, I still need this.  If the qdisc gets loaded with multiqueue 
> >>turned on, I can just use the value of band to assign
> >>skb->queue_mapping.  But if the qdisc is loaded without multiqueue
> >>support, then I need to assign a value of zero to queue_mapping, or 
> >>not assign it at all (it will be zero'd out before the call to 
> >>->enqueue() in dev_queue_xmit()).  But I'd rather not have a 
> >>conditional in the hotpath checking if the qdisc is multiqueue; I'd 
> >>rather have the array to match the bands so I can just do 
> an assignment.
> >>
> >>What do you think?
> > 
> > 
> > 
> > I very much doubt that it has any measurable impact. You 
> can also add 
> > a small inline function
> > 
> > void skb_set_queue_mapping(struct sk_buff *skb, unsigned int queue)
> 
> 
> OK I didn't really listen obviously :) A compile time option 
> won't help. Just remove it and assign it conditionally.

Sounds good.  Thanks Patrick.

-PJ
