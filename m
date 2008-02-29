From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Bug 10071] kernel hang in inet_init (PREEMPT_RCU problem)
Date: Thu, 28 Feb 2008 20:32:35 -0800
Message-ID: <20080229043235.GA25167@linux.vnet.ibm.com>
References: <bug-10071-11547@http.bugzilla.kernel.org/> <20080228205303.261D311D108@picon.linux-foundation.org> <20080228213457.GA2770@ami.dom.local> <20080229005823.GF14104@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@bugzilla.kernel.org,
	Yannick Dirou <yannick.dirou@axetic.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:54794 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbYB2Ecr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 23:32:47 -0500
Content-Disposition: inline
In-Reply-To: <20080229005823.GF14104@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 04:58:23PM -0800, Paul E. McKenney wrote:
> On Thu, Feb 28, 2008 at 10:34:57PM +0100, Jarek Poplawski wrote:
> > On Thu, Feb 28, 2008 at 12:53:03PM -0800, bugme-daemon@bugzilla.kernel.org wrote:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=10071
> > ...
> > > ------- Comment #17 from yannick.dirou@axetic.com  2008-02-28 12:53 -------
> > > bingo with classic rcu
> > 
> > Congratulations Yannick!
> > 
> > So, it seems mainly RCU vs. timer(?) problem. I send CC of this message
> > to RCU author, linux-kernel and netdev lists.
> 
> Interesting!  Any chance of a pointer to the original messages?
> A quick Google search and a look at LKML showed me nothing.  :-/

Thanks to Raphael for pointing me at the above bugzilla URL!

Yannick,

Would you be willing to try your test again after applying the
patch in http://lkml.org/lkml/2008/2/2/11 and rebuilding your
kernel?

This patch does not appear to be in 2.6.25-rc3.  :-(

I am reposting this patch separately.

							Thanx, Paul
