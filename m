From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in net_rx_action
Date: Thu, 27 Mar 2008 22:56:49 +0100
Message-ID: <200803272256.50454.rjw@sisk.pl>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <1206621014.8514.563.camel@twins> <20080327124928.GE2845@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47447 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756482AbYC0V5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 17:57:19 -0400
In-Reply-To: <20080327124928.GE2845@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 27 of March 2008, Jarek Poplawski wrote:
> On Thu, Mar 27, 2008 at 01:30:14PM +0100, Peter Zijlstra wrote:
> ...
> > My guess is that it is a race between polling the device and irq pushing
> > the packet. That is, normally the IRQ handler wins and netpoll doesn't
> > have anything to do and it doesn't traverse this code path.
> > 
> > (although I must admit to being a little out of my depth here)
> 
> Probably you're right but there were really a lot of testing and
> stressing netconsole for misterious lockups for quite a long time
> with this new napi, so it's hard to believe this was hidden so
> well...

I assume there will be a patch posted for this issue.  Correct?

Rafael
