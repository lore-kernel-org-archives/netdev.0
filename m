From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue
 hardware support API
Date: Thu, 28 Jun 2007 13:39:42 -0700 (PDT)
Message-ID: <20070628.133942.90822934.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F061E@orsmsx414.amr.corp.intel.com>
	<468409E4.7000603@trash.net>
	<46840CD8.7000308@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765357AbXF1UjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 16:39:23 -0400
In-Reply-To: <46840CD8.7000308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 28 Jun 2007 15:32:40 -0400

> Patrick McHardy wrote:
> > Yes, but there are users that don't go through qdiscs, like netpoll,
> > Having them check the QDISC_RUNNING bit seems ugly.
> 
> Is netpoll the only such user?
> 
> netpoll tends to be a special case in every sense of the word, and I 
> wish it was less so :/

Seconded.

I'm perfectly happy to consider rearchitecting of netpoll to something
that works better.
