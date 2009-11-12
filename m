From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] Documentation: rw_lock lessons learned
Date: Thu, 12 Nov 2009 15:00:29 -0800
Message-ID: <20091112150029.1a26c641@nehalam>
References: <4AF9C540.5090403@gmail.com>
	<20091110180646.2e5859a8@nehalam>
	<4AFAEF78.4080807@gmail.com>
	<20091111093724.4f40a48d@nehalam>
	<4AFBEC44.9030409@gmail.com>
	<4AFC5E3F.7070609@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49844 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbZKLXAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 18:00:51 -0500
In-Reply-To: <4AFC5E3F.7070609@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 14:13:03 -0500
Stephen Clark <sclark46@earthlink.net> wrote:

> William Allen Simpson wrote:
> > In recent weeks, two different network projects erroneously
> > strayed down the rw_lock path.  Update the Documentation
> > based upon comments by Eric Dumazet and Paul E. McKenney in
> > those threads.
> > 
> > Merged with editorial changes by Stephen Hemminger.
> > 
> > Signed-off-by: William.Allen.Simpson@gmail.com
> > Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> >  Documentation/spinlocks.txt |  186 
> > ++++++++++++++++++++-----------------------
> >  1 files changed, 86 insertions(+), 100 deletions(-)
> > 
> 
> How up to date is this doc?
> 
> http://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/index.html
> 

Out of date.
1. Missing mutex's which have largely replaced semaphores.

2. Missing change to lock initialization in later kernels.

3. Missing description of lock dependency checker which should be in same guide.
