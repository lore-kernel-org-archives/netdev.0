From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 12:27:20 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0657@orsmsx414.amr.corp.intel.com>
References: <46840AF5.4020209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39880 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757619AbXF1T1V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:27:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46840AF5.4020209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Waskiewicz Jr, Peter P wrote:
> >>[...]
> >>The only reasonable thing it can do is not care about 
> multiqueue and 
> >>just dequeue as usual. In fact I think it should be an error to 
> >>configure multiqueue on a non-root qdisc.
> > 
> > 
> > Ack.  This is a thought process that trips me up from time 
> to time...I 
> > see child qdisc, and think that's the last qdisc to dequeue 
> and send 
> > to the device, not the first one to dequeue.  So please 
> disregard my 
> > comments before; I totally agree with you.  Great catch 
> here; I really 
> > like the prio_classify() cleanup.
> 
> 
> Thanks. This updated patch makes configuring a non-root qdisc 
> for multiqueue an error.
> 

The patch looks fine to me.  Thanks Patrick.

-PJ
