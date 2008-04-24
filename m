From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 16:03:52 +0100
Message-ID: <20080424160352.30f2dd5b@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<481096C3.2020206@redhat.com>
	<20080424152436.6cf53c1b@the-village.bc.nu>
	<4810A46B.1090809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:39528 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755499AbYDXPec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:34:32 -0400
In-Reply-To: <4810A46B.1090809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You didn't read what I wrote.

The feeling is mutual

> For those the implementer must ensure that during the development no
> value is used which can conflict with any current and future assigned
> value and not with any other development.

Kernel socket type values are assigned by the kernel team so that
isn't a problem.

> > Every other property of a socket via accept() is inherited from the
> > parent. Making one property different would be bizarre and ugly.
> 
> Implementing this would visibly change existing code and it would
> actively violate POSIX.  Not a good idea.

POSIX has no interface for this new behaviour you propose so that is
complete crap. The moment you use one of these features you stepped
outside of the POSIX spec - and you know that. If there was an existing
standard we wouldn't have a problem.

Alan
