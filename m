From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 04/18] flag parameters: anon_inode_getfd extension
Date: Sun, 4 May 2008 21:56:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042156010.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gktV029823@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:54285 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbYEEE4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:56:47 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A927> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:56:46 -0400
In-Reply-To: <200805050342.m453gktV029823@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> This patch just extends the anon_inode_getfd interface to take an additional
> parameter with a flag value.  The flag value is passed on to
> get_unused_fd_flags in anticipation for a use with the O_CLOEXEC flag.
> 
> No actual semantic changes here, the changed callers all pass 0 for now.
> 
> 
>  fs/anon_inodes.c            |    9 +++++----
>  fs/eventfd.c                |    2 +-
>  fs/eventpoll.c              |    2 +-
>  fs/signalfd.c               |    3 ++-
>  fs/timerfd.c                |    2 +-
>  include/linux/anon_inodes.h |    2 +-
>  6 files changed, 11 insertions(+), 9 deletions(-)
> 
> 
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


