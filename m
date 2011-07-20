From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Auto-detect the presence of setns in libc
Date: Wed, 20 Jul 2011 15:16:51 -0700
Message-ID: <20110720151651.37895522@nehalam.ftrdhcpuser.net>
References: <m1mxgfkr3g.fsf@fess.ebiederm.org>
	<CAEik5nOO9KQoEdvPUGwLBDJqOP9OWgz=G-3KMyvwiu4nwoyb=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Dan McGee <dan@archlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab1GTWQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 18:16:48 -0400
In-Reply-To: <CAEik5nOO9KQoEdvPUGwLBDJqOP9OWgz=G-3KMyvwiu4nwoyb=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2011 19:34:04 -0500
Dan McGee <dan@archlinux.org> wrote:

> On Fri, Jul 15, 2011 at 7:26 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > If libc has setns present use that version instead of
> > rolling the syscall wrapper by hand.
> >

I am more inclined to get rid of the wrapper completely
and just not put setns support in if libc doesn't support it.

