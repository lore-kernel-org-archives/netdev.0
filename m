From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] TCP Illinois congestion control (rev3)
Date: Fri, 20 Apr 2007 18:00:51 -0700
Message-ID: <20070420180051.75b18e2e@localhost.localdomain>
References: <20070403091656.769e5368@localhost.localdomain>
	<200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu>
	<20070404080743.5e67245a@localhost.localdomain>
	<20070420.170813.107209822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shaoliu@uiuc.edu, chaitanya_tk@tamu.edu, jgarrison@tamu.edu,
	srikant@ifp.uiuc.edu, tbasar@control.csl.uiuc.edu,
	jheffner@psc.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35931 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916AbXDUBB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 21:01:56 -0400
In-Reply-To: <20070420.170813.107209822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Apr 2007 17:08:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 4 Apr 2007 08:07:43 -0700
> 
> > This is an implementation of TCP Illinois invented by Shao Liu
> > at University of Illinois. It is a another variant of Reno which adapts
> > the alpha and beta parameters based on RTT. The basic idea is to increase
> > window less rapidly as delay approaches the maximum. See the papers
> > and talks to get a more complete description.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> I've applied this to net-2.6.22, let me know if there are any
> follow-on bug fixes I need to add as well.
> 
> Thanks!

I have a new version ready.
