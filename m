From: Paul Moore <paul.moore@hp.com>
Subject: Re: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Mon, 14 Jan 2008 18:19:32 -0500
Message-ID: <200801141819.33203.paul.moore@hp.com>
References: <30887.1200209733@turing-police.cc.vt.edu> <200801141407.46345.paul.moore@hp.com> <4382.1200351868@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3083 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbYANXTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 18:19:41 -0500
In-Reply-To: <4382.1200351868@turing-police.cc.vt.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 January 2008 6:04:28 pm Valdis.Kletnieks@vt.edu wrote:
> On Mon, 14 Jan 2008 14:07:46 EST, Paul Moore said:
> > http://git.infradead.org/?p=users/pcmoore/lblnet-2.6_testing;a=commitdiff
> >;h=02f1c89d6e36507476f78108a3dcc78538be460b
>
> Initial testing indicates that 2.6.24-rc6-mm1 plus this one commit is
> behaving itself correctly - my Tcl test case that reliably demonstrated
> wedges during SYN handling is definitively fixed, and the current issue
> with hangs with data pending seems to be gone as well (after admittedly
> light testing).
>
> Thanks for finding the commit that fixed it...

No problem, glad to hear that fixed the problem.  It's already in Linus' tree 
so any future -mm kernels as well as 2.6.24 should be problem-free, at least 
with respect to this ;)

-- 
paul moore
linux security @ hp
