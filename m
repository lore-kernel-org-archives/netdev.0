From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 13:50:47 -0700 (PDT)
Message-ID: <20070625.135047.124049631.davem@davemloft.net>
References: <467BF65F.4000803@trash.net>
	<D5C1322C3E673F459512FB59E0DDC32903179937@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755463AbXFYUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 16:50:29 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903179937@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 25 Jun 2007 10:14:37 -0700

> > This patch adds a new attribute type that can be used to 
> > replace non-nested attributes that contain structures by 
> > nested ones in a compatible way.
> > 
> > This can be used in cases like Peter's who is trying to 
> > extend sch_prio, which currently uses a fixed structure 
> > without any holes.
> > 
> > Switching to nested attributes makes sure that the next 
> > person won't run into the same problem.
> 
> I've been using this patch and the IPROUTE2 patches Patrick has proposed
> with no issues.  Can someone else look at these patches when they have
> time?  I'd be interested in seeing them make it into 2.6.23.

I've just put Patrick's patch into the net-2.6.23 tree.
