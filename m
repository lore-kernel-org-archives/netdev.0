From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 5/7] bnx2: use netdev_irqname
Date: Tue, 21 Jun 2011 11:17:56 -0700
Message-ID: <20110621111756.5c7541ba@nehalam.ftrdhcpuser.net>
References: <20110621170541.309890798@vyatta.com>
	<20110621170658.788401517@vyatta.com>
	<1308679911.2743.45.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54131 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559Ab1FUSR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 14:17:59 -0400
In-Reply-To: <1308679911.2743.45.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 19:11:51 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2011-06-21 at 10:05 -0700, Stephen Hemminger wrote:
> 
> > Also increase size of irq name to account for longer device names.
> > Original code was broken for full size names.
> [...]
> 
> We should define a macro for the maximum netdev IRQ name length.  I
> think this would be IFNAMSIZ + 1 + 2 + 1 + 5 (2 characters for queue
> type; up to 5 digits for 16-bit queue index).
> 
> Ben.
> 

Probably should put it in the queue structures?
