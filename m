From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 14:01:31 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179CFB@orsmsx414.amr.corp.intel.com>
References: <20070625.135047.124049631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>,
	<shemminger@linux-foundation.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26253 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755419AbXFYVBd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 17:01:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070625.135047.124049631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 25 Jun 2007 10:14:37 -0700
> 
> > > This patch adds a new attribute type that can be used to replace 
> > > non-nested attributes that contain structures by nested ones in a 
> > > compatible way.
> > > 
> > > This can be used in cases like Peter's who is trying to extend 
> > > sch_prio, which currently uses a fixed structure without 
> any holes.
> > > 
> > > Switching to nested attributes makes sure that the next 
> person won't 
> > > run into the same problem.
> > 
> > I've been using this patch and the IPROUTE2 patches Patrick has 
> > proposed with no issues.  Can someone else look at these 
> patches when 
> > they have time?  I'd be interested in seeing them make it 
> into 2.6.23.
> 
> I've just put Patrick's patch into the net-2.6.23 tree.

Awesome Dave!!  Thank you very much. :)

-PJ Waskiewicz
