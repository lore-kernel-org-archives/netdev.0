From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative^2 to sys_indirect: socket, socketpair
Date: Thu, 24 Apr 2008 18:23:52 +0100
Message-ID: <20080424182352.693f818b@the-village.bc.nu>
References: <200804241618.m3OGI9kd013025@devserv.devel.redhat.com>
	<20080424170325.569afa43@the-village.bc.nu>
	<4810B75B.20202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:33531 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752238AbYDXRxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 13:53:23 -0400
In-Reply-To: <4810B75B.20202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Apr 2008 09:37:47 -0700
Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Alan Cox wrote:
> 
> >> -int sock_map_fd(struct socket *sock)
> >> +static int sock_map_fd_flags(struct socket *sock, int flags)
> 
> sock_map_fd is exported to modules.  Isn't it a big no-no to change
> those interfaces?

Upstream no. We just fix the users. The aversion to changing exported
symbols between kernels is strictly an enterprise vendor thing. 

Alan
