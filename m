From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: sys_paccept: disable paccept() until API design is resolved
Date: Wed, 17 Sep 2008 11:22:39 +1000
Message-ID: <200809171122.40442.nickpiggin@yahoo.com.au>
References: <48CFA10D.2010106@gmail.com> <48D03E85.9030808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alan Cox <alan@redhat.com>, Jakub Jelinek <jakub@redhat.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	Roland McGrath <roland@redhat.com>,
	Oleg Nesterov <oleg@tv-sign.ru>, Christoph Hellwig <hch@lst.de>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.mail.mud.yahoo.com ([209.191.85.213]:35444 "HELO
	smtp103.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752593AbYIQBXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 21:23:32 -0400
In-Reply-To: <48D03E85.9030808@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 September 2008 09:17, Ulrich Drepper wrote:
> Michael Kerrisk wrote:
> > The patch below disables the new sys_paccept() for now.  Please
> > apply for 2.6.27-rc, so that we do not release this API into
> > the wild before a conclusion has been reached about its design.
>
> There is no reason for that.

There is a good reason, and that is that if there is any questioning
of a patch that adds a userspace API, then it is much better to be
safe than sorry.

We don't get enough people reviewing these things as is, so
ignoring the review we do get is not the right thing to do. There
is much more harm in releasing the kernel with a poor API than
just holding off for another release until issues are sorted out.
