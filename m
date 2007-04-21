From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP Illinois congestion control (rev3)
Date: Fri, 20 Apr 2007 17:08:13 -0700 (PDT)
Message-ID: <20070420.170813.107209822.davem@davemloft.net>
References: <20070403091656.769e5368@localhost.localdomain>
	<200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu>
	<20070404080743.5e67245a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shaoliu@uiuc.edu, chaitanya_tk@tamu.edu, jgarrison@tamu.edu,
	srikant@ifp.uiuc.edu, tbasar@control.csl.uiuc.edu,
	jheffner@psc.edu, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752277AbXDUAIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:08:10 -0400
In-Reply-To: <20070404080743.5e67245a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 4 Apr 2007 08:07:43 -0700

> This is an implementation of TCP Illinois invented by Shao Liu
> at University of Illinois. It is a another variant of Reno which adapts
> the alpha and beta parameters based on RTT. The basic idea is to increase
> window less rapidly as delay approaches the maximum. See the papers
> and talks to get a more complete description.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

I've applied this to net-2.6.22, let me know if there are any
follow-on bug fixes I need to add as well.

Thanks!
