From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 07/18] flag parameters: timerfd_create
Date: Sun, 4 May 2008 21:50:52 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042150340.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gkOX029832@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:51636 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbYEEEuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:50:54 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A91D> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:50:53 -0400
In-Reply-To: <200805050342.m453gkOX029832@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> The timerfd_create syscall already has a flags parameter.  It just is
> unused so far.  This patch changes this by introducing the TFD_CLOEXEC
> flag to set the close-on-exec flag for the returned file descriptor.
> 
> A new flag TFD_CLOEXEC is used instead of reusing O_CLOEXEC to prevent
> exhaustion of the int bit field in case we need more flags.
> 
> The following test must be adjusted for architectures other than x86 and
> x86-64 and in case the syscall numbers changed.

> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


