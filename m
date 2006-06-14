From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.17: networking bug??
Date: Wed, 14 Jun 2006 07:18:21 +0200
Message-ID: <200606140718.21609.ak@suse.de>
References: <Pine.LNX.4.64.0606131048550.5498@g5.osdl.org> <448F0D4B.30201@rtr.ca> <20060613.142603.48825062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml@rtr.ca, jheffner@psc.edu, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:7371 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S964874AbWFNFSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 01:18:35 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060613.142603.48825062.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Also, as John Heffner mentioned, even if we could detect the broken
> boxes you can't just "turn off window scaling" after it's been
> negotiated.  It's immutably active for the entire connection once
> enabled.

In theory you could set a bit in the dst entry and not use it next time
you connect to that host. That would be ok for web browsing at least
when creates new connections all the time.

But it's unclear how to even detect this situation reliably

e.g. you don't want to disable it just because there was a bit of 
packet loss on a connection to a particular host earlier and there
is no clear heuristic to detect that this particular problem happened.
 
> So the broken boxes, which to be honest are few and far between these
> days, need to go, they really do.

Agreed.

-Andi
