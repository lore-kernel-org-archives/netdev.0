From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Subject: Re: [PATCH 08/18] flag parameters: epoll_create
Date: Wed, 7 May 2008 01:10:53 +0200
Message-ID: <cfd18e0f0805061610i48146b3fra3ac378643d51c9e@mail.gmail.com>
References: <200805050342.m453gk49029835@devserv.devel.redhat.com>
	 <1210107990.7323.347.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0805061540560.25162@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Matthew Helsley" <matthltc@us.ibm.com>,
	"Ulrich Drepper" <drepper@redhat.com>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "Davide Libenzi" <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:27486 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325AbYEFXKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 19:10:54 -0400
Received: by rv-out-0506.google.com with SMTP id l9so40741rvb.1
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 16:10:53 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0805061540560.25162@alien.or.mcafeemobile.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2008 at 12:41 AM, Davide Libenzi <davidel@xmailserver.org> wrote:
>
> On Tue, 6 May 2008, Matthew Helsley wrote:
>
> >
> > On Sun, 2008-05-04 at 23:42 -0400, Ulrich Drepper wrote:
> > > This patch adds the new epoll_create2 syscall.  It extends the old epoll_create
> > > syscall by one parameter which is meant to hold a flag value.  In this
> > > patch the only flag support is EPOLL_CLOEXEC which causes the close-on-exec
> > > flag for the returned file descriptor to be set.
> >
> > Davide, Ulrich,
> >
> >       A minor question: Why did you choose to pass the seemingly useless
> > "size" parameter into the new epoll_create2 system call? I did some
> > googling for previous threads with this series and couldn't find a
> > discussion on why you chose to keep it.
>
> The very first implementations were using an hash, and that was a size
> hint.

So, why not simply remove this argument in the new API, since it is now useless?
