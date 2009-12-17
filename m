From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Thu, 17 Dec 2009 13:24:51 -0800
Message-ID: <20091217132451.b168a796.akpm@linux-foundation.org>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
	<20091216154713.f082e7cf.akpm@linux-foundation.org>
	<4B2A9A40.90203@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51804 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760002AbZLQV1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:27:12 -0500
In-Reply-To: <4B2A9A40.90203@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2009 21:53:20 +0100
N__meth M__rton <nm127@freemail.hu> wrote:

> Hi,
> 
> I bisected the problem, see http://bugzilla.kernel.org/show_bug.cgi?id=14794
> for details. Any idea what is the relation between this problem and the found
> patch?
> 

Please don't update this report via the bugillla interface.  See
"(switched to email.  Please respond via emailed reply-to-all, not via
the bugzilla web interface)."

: 61cbe54d9479ad98283b2dda686deae4c34b2d59 is the first bad commit
: commit 61cbe54d9479ad98283b2dda686deae4c34b2d59
: Author: Mike Galbraith <efault@gmx.de>
: Date:   Wed Sep 9 15:41:37 2009 +0200
:
:    sched: Keep kthreads at default priority

Strange.  Might be a timing thing bu a) I doubt if any kernel threads
are involved in maintaining a DHCP lease and b) even if they were, such
a race wouldn't be this repeatable.

Maybe it was a bisection glitch.  Did you try reverting just that
patch, see if it fixed things again?

