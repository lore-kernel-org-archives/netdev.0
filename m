From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Wed, 15 Feb 2012 14:02:32 +0100
Message-ID: <1329310952.2293.80.camel@twins>
References: <bug-42754-27@https.bugzilla.kernel.org/>
	 <20120209191317.2fbad57b.akpm@linux-foundation.org>
	 <20120210122657.GA9347@smp.if.uj.edu.pl>
	 <20120212175004.GM3737@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Witold Baryluk <baryluk@smp.if.uj.edu.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	rostedt@goodmis.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40269 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894Ab2BONCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:02:40 -0500
In-Reply-To: <20120212175004.GM3737@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-02-12 at 09:50 -0800, Paul E. McKenney wrote:
> > I do not know why lockdep is disabled, because I configured kernel to
> > keep telling my about lock dependency problems even after showing first
> > one. AFAIK. 

That setting is only relevant to RCU, normal lockdep reports will always
disable lockdep.
