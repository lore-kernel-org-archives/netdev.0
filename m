From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
 net_rx_action
Date: Thu, 27 Mar 2008 14:44:08 -0700 (PDT)
Message-ID: <20080327.144408.156087783.davem@davemloft.net>
References: <20080327.040334.25440988.davem@davemloft.net>
	<47EB8C06.4030306@better.se>
	<20080327123248.GD2845@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcus@better.se, a.p.zijlstra@chello.nl,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, mingo@elte.hu
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759959AbYC0VoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:44:08 -0400
In-Reply-To: <20080327123248.GD2845@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 27 Mar 2008 13:32:48 +0100

> On Thu, Mar 27, 2008 at 12:59:02PM +0100, Marcus Better wrote:
> > David Miller wrote:
> >> Can some test if using local_irq_{save,restore}() in
> >> napi_complete() cures this lockdep warning?
> 
> Isn't it now justified enough without lockdep's ack?

Absolutely, but I want to know that the problem is solved
and confirmed by a tester.
