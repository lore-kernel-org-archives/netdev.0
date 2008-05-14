From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Tue, 13 May 2008 21:43:02 -0700
Message-ID: <20080513214302.876c5f47.akpm@linux-foundation.org>
References: <200805062118.m46LI74j004096@devserv.devel.redhat.com>
	<20080512201341.9ead6a9a.akpm@linux-foundation.org>
	<482910FA.1080703@redhat.com>
	<20080512.210225.167924945.davem@davemloft.net>
	<20080512220416.ef9a9645.akpm@linux-foundation.org>
	<482922E2.3040902@redhat.com>
	<20080512221917.07cf7b06.akpm@linux-foundation.org>
	<48292A5A.4050606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48360 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbYENEnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 00:43:25 -0400
In-Reply-To: <48292A5A.4050606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 May 2008 22:42:50 -0700 Ulrich Drepper <drepper@redhat.com> wrote:

> Andrew Morton wrote:
> > Different bug, I think.
> > 
> > net/socket.c: In function 'sys_paccept':
> > net/socket.c:1543: error: implicit declaration of function 'set_restore_sigmask'
> 
> Right, that's the signal mask stuff.  Should be fixed by the other patch
> I sent.

mips allmodconfig is unhappy still.


net/socket.c: In function `sys_socket':
net/socket.c:1225: error: `SOCK_CLOEXEC' undeclared (first use in this function)
net/socket.c:1225: error: (Each undeclared identifier is reported only once
net/socket.c:1225: error: for each function it appears in.)
net/socket.c:1226: error: `SOCK_NONBLOCK' undeclared (first use in this function)
net/socket.c:1227: error: `SOCK_TYPE_MASK' undeclared (first use in this function)
net/socket.c: In function `sys_socketpair':
net/socket.c:1268: error: `SOCK_TYPE_MASK' undeclared (first use in this function)
net/socket.c:1269: error: `SOCK_CLOEXEC' undeclared (first use in this function)
net/socket.c:1269: error: `SOCK_NONBLOCK' undeclared (first use in this function)
net/socket.c: In function `do_accept':
net/socket.c:1438: error: `SOCK_CLOEXEC' undeclared (first use in this function)
net/socket.c:1438: error: `SOCK_NONBLOCK' undeclared (first use in this function)
