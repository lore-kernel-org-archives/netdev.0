From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [Bug 42754] New: BUG: sleeping function called from invalid
 context at mm/memory.c:3924
Date: Fri, 10 Feb 2012 16:39:41 +0100
Message-ID: <1328888381.25989.6.camel@laptop>
References: <bug-42754-27@https.bugzilla.kernel.org/>
	 <20120209191317.2fbad57b.akpm@linux-foundation.org>
	 <20120210122657.GA9347@smp.if.uj.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39725 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab2BJPjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 10:39:48 -0500
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1RvsZd-0007ac-RC
	for netdev@vger.kernel.org; Fri, 10 Feb 2012 15:39:45 +0000
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RvsZd-0005Pz-Hw
	for netdev@vger.kernel.org; Fri, 10 Feb 2012 15:39:45 +0000
In-Reply-To: <20120210122657.GA9347@smp.if.uj.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-10 at 13:26 +0100, Witold Baryluk wrote:
> Well, there is few problems before this message, they are already
> reported:

Never report a bug if it isn't the first -- yes it might be a real
problem, but once we go splat you simply shouldn't trust the state of
your system. Fix that problem, then get on with the next.
