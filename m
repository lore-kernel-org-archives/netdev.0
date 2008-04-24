From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 16:27:03 +0100
Message-ID: <20080424162703.1eec01a2@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<481096C3.2020206@redhat.com>
	<20080424152436.6cf53c1b@the-village.bc.nu>
	<4810A46B.1090809@redhat.com>
	<20080424160352.30f2dd5b@the-village.bc.nu>
	<4810AB29.5030604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50475 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757596AbYDXPzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 11:55:36 -0400
In-Reply-To: <4810AB29.5030604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Alan Cox wrote:
> > Kernel socket type values are assigned by the kernel team so that
> > isn't a problem.
> 
> Again, it's not about assigned values.  It about those not yet assigned.

Earth calling Ulrich, Earth calling Ulrich...

"Kernel socket type values are assigned by the kernel team so that isn't a
problem."

Believe it or not we have the compute capability between us to not
accidentally reassign values we assigned to one thing to something else.

> Oh really?  You open a server socket, use fcntl(FD_CLOEXEC), and then
> accept(). 

And your behaviour just became OS specific....

Alan
