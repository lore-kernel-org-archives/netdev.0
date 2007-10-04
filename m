From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Vague maybe ppp-related panic report for 2.6.23-rc9
Date: Thu, 04 Oct 2007 13:53:25 -0700
Message-ID: <adahcl6bnzu.fsf@cisco.com>
References: <ada4ph6da05.fsf@cisco.com>
	<20071004.135113.48807663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:61641 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978AbXJDUx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 16:53:27 -0400
In-Reply-To: <20071004.135113.48807663.davem@davemloft.net> (David Miller's message of "Thu, 04 Oct 2007 13:51:13 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I don't want to jump the gun on the analysis but it just might
 > be the packet sharing fixes Herbert put in a short time ago.
 > 
 > What you could do is go back to say rc2 and see if you still get
 > the panics, then bisect from there to narrow it down.
 > 
 > If rc2 still gives the panic, it's something else, perhaps device
 > specific.

OK thanks.  I'm still trying to find a good way to reproduce it, so
I'm going to try to get it to happen with -rc9 while running in the
console, and at least take a picture of the backtrace.  If I find a
good way to make it happen then I'll try rc2 and let you know.

 - R.
