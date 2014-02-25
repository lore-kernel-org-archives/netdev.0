From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Tue, 25 Feb 2014 09:23:41 +0100
Message-ID: <20140225082341.GA9965@breakpoint.cc>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
 <20140224.191410.698948363517952588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53539 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599AbaBYIXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 03:23:45 -0500
Content-Disposition: inline
In-Reply-To: <20140224.191410.698948363517952588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 17 Feb 2014 22:57:48 +0100
> 
> > Three counters are added:
> > - one to track when we went from non-zero to zero window
> > - one to track the reverse
> > - one counter incremented when we want to announce zero window.
> > 
> > The latter is added because it can show cases where we want to close the
> > window but can't because we would shrink window.
> > 
> > Suggested-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  Eric, is this what you had in mind?
> > 
> >  I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
> >  scenario and, as expected, only TCPWANTZEROWINDOW increases.
> 
> What is happening with this patch?  The discussion just died out.

I guess Eric is busy with TCP usec timer resolution changes.
You can mark the patch as defered if you want; I can re-send it for
3.16 if needed.
