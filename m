From: Matthew Helsley <matthltc@us.ibm.com>
Subject: Re: [PATCH 08/18] flag parameters: epoll_create
Date: Tue, 06 May 2008 14:06:29 -0700
Message-ID: <1210107990.7323.347.camel@localhost.localdomain>
References: <200805050342.m453gk49029835@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:35103 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933616AbYEFWMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 18:12:35 -0400
In-Reply-To: <200805050342.m453gk49029835@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-05-04 at 23:42 -0400, Ulrich Drepper wrote:
> This patch adds the new epoll_create2 syscall.  It extends the old epoll_create
> syscall by one parameter which is meant to hold a flag value.  In this
> patch the only flag support is EPOLL_CLOEXEC which causes the close-on-exec
> flag for the returned file descriptor to be set.

Davide, Ulrich,

	A minor question: Why did you choose to pass the seemingly useless
"size" parameter into the new epoll_create2 system call? I did some
googling for previous threads with this series and couldn't find a
discussion on why you chose to keep it.

Cheers,
	-Matt Helsley

