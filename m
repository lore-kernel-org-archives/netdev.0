From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 27 Jun 2007 17:31:39 -0700 (PDT)
Message-ID: <20070627.173139.83620684.davem@davemloft.net>
References: <1182983565.5155.12.camel@localhost>
	<20070627.155457.35508432.davem@davemloft.net>
	<1182989747.5155.89.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763762AbXF1AbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 20:31:20 -0400
In-Reply-To: <1182989747.5155.89.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 27 Jun 2007 20:15:47 -0400

> On Wed, 2007-27-06 at 15:54 -0700, David Miller wrote:
> 
> > The thing that's really important is that the value is not so
> > large such that the TX ring can become empty.
> 
> In the case of batching, varying the values makes a difference.
> The logic is that if you can tune it so that the driver takes
> "sufficiently long" to stay closed the more packets you accumulate at
> the qdisc and the more you can batch to the driver (when it opens up). 
> Deciding what "sufficiently long" is an art - and i am sure speed
> dependent. With e1000 at gige 128 seems to be a good value, going above
> or below that gave lesser performance.

Right.  And another thing you want to moderate is lock hold
times, perhaps even at the slight expense of performance.
