From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC NET_SCHED 00/03]: ktime + nano-second clock resolution for
 packet schedulers
Date: Mon, 5 Mar 2007 11:09:28 -0800
Message-ID: <20070305110928.25ce596c@freekitty>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>
	<20070304.162557.112625456.davem@davemloft.net>
	<45EC5682.6000406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60675 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932195AbXCETJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 14:09:37 -0500
In-Reply-To: <45EC5682.6000406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Mar 2007 18:42:26 +0100
Patrick McHardy <kaber@trash.net> wrote:

> David Miller wrote:
> > Frankly, I think now that we have ktime and all of the proper generic
> > infrastructure to do this stuff properly, I think we should just use
> > ktime for the packet scheduler across the board and just delete all of
> > that old by-hand timekeeping selection crap from pkt_sched.h
> 
> Sounds good, I'm going to remove all other clock sources.
> Will resend in a couple of days after fixing a few more
> problems I noticed.
> 

Don't bother changing netem. I have a version that uses hrtimer's
and doesn't use PSCHED() clock source anymore.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
