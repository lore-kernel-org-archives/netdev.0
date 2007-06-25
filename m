From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RTNETLINK]: Add nested compat attribute
Date: Mon, 25 Jun 2007 10:14:37 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179937@orsmsx414.amr.corp.intel.com>
References: <467BF65F.4000803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Patrick McHardy" <kaber@trash.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26196 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbXFYROj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:14:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467BF65F.4000803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This patch adds a new attribute type that can be used to 
> replace non-nested attributes that contain structures by 
> nested ones in a compatible way.
> 
> This can be used in cases like Peter's who is trying to 
> extend sch_prio, which currently uses a fixed structure 
> without any holes.
> 
> Switching to nested attributes makes sure that the next 
> person won't run into the same problem.

I've been using this patch and the IPROUTE2 patches Patrick has proposed
with no issues.  Can someone else look at these patches when they have
time?  I'd be interested in seeing them make it into 2.6.23.

Thanks!!

-PJ Waskiewicz
