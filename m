From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sat, 14 Jun 2008 03:38:38 -0700 (PDT)
Message-ID: <20080614.033838.207353824.davem@davemloft.net>
References: <20080614062758.GA23803@elte.hu>
	<20080614.001428.26649070.davem@davemloft.net>
	<20080614081656.GA27820@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754728AbYFNKii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 06:38:38 -0400
In-Reply-To: <20080614081656.GA27820@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 14 Jun 2008 10:16:56 +0200

> * David Miller <davem@davemloft.net> wrote:
> 
> > This warning was added by Arjan in 2.6.25 FYI in order to diagnose the 
> > not-normal cases better.
> 
> ok, should we then remove that warning, if it's spurious? kerneloops.org 
> has picked up a few other instances of this warning as well:
> 
>   http://www.kerneloops.org/searchfile.php?search=net%2Fsched%2Fsch_generic.c&btnG=Filename+Search

Sorry, I misphrased that.

It always has warned.

The change is that it also now gives a stack backtrace.
