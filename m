From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 16:42:26 +0100
Message-ID: <20080424164226.415cedeb@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>
	<20080424.083908.147395158.davem@davemloft.net>
	<517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	torvalds@linux-foundation.org, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: "Michael Kerrisk" <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:55350 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751623AbYDXQLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:11:24 -0400
In-Reply-To: <517f3f820804240903y788102bar5c7d1fa9bcee1c8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But this approach fixes just one of the interfaces.  There are 7 or 8
> other interfaces that need to solve the same problem.  What about
> those?

Actually it seems to fix most of them. I accept Jakub's observation we
need a "paccept()" or similar.

> It strikes me to be cleanest to use the same solution for all of them
> -- i.e., new syscalls (seems simplest) or sys_indirect() -- including
> socket().

New syscalls make the interface more complex and harder to learn. They
make it harder to tweak applications neatly to use the new API if
present. They are not immediately obvious from knowling the existing API.

What we don't want to do is to end up with a thousand weird system calls
as Windows NT did where nobody can actually understand chunks of code
without looking calls up in books as they go.
