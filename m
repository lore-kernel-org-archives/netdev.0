From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Sat, 12 Dec 2009 02:24:39 -0800
Message-ID: <20091212022439.fae86037.akpm@linux-foundation.org>
References: <20091211.181712.211179737.davem@davemloft.net>
	<4B236C18.4050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43160 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755172AbZLLKZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 05:25:06 -0500
In-Reply-To: <4B236C18.4050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Dec 2009 05:10:32 -0500 William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> David Miller wrote:
> > David S. Miller (4):
> >       Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
> >       tcp: Remove runtime check that can never be true.
> 
> This is a poor patch that was never sent to the netdev list for review.

It's better than the original code, which was checking to see whether a
u8 exceeded 536!

> Please substitute the better patch in the main tree.

Linus won't remove a commit from the middle of David's merge and
replace it with some unchangelogged, un-signed-off alternative.

An appropriate way to handle this is to prepare a new patch against
Linus or David's tree after this merge has been performed.  Package
that patch in the usual way and send it to the usual recipients. That's
the no-fuss, no-drama, stuff-gets-done path.
