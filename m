From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 16:38:35 +0100
Message-ID: <20080424163835.55520b5b@the-village.bc.nu>
References: <20080424160352.30f2dd5b@the-village.bc.nu>
	<20080424154441.GG2255@devserv.devel.redhat.com>
	<20080424162444.1c5b9ba2@the-village.bc.nu>
	<20080424.090008.232544945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jakub@redhat.com, drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50797 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760219AbYDXQHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 12:07:08 -0400
In-Reply-To: <20080424.090008.232544945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Apr 2008 09:00:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Thu, 24 Apr 2008 16:24:44 +0100
> 
> > BTW in 4.4BSD and derivatives if I remember rightly F_CLOEXEC *is*
> > inherited across accept() so I doubt any user space software will be too
> > upset by such a shift.
> 
> It actually doesn't.
> 
> Just like in Linux, no file descriptor flags are inherited.

NDELAY certainly appears to be looking at Stevens.
