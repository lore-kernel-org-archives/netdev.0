From: Florian Westphal <fw@strlen.de>
Subject: Re: Enable syn cookies by default
Date: Fri, 16 Oct 2009 21:56:04 +0200
Message-ID: <20091016195604.GA8704@Chamillionaire.breakpoint.cc>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
 <20091016085541.GA7393@ff.dom.local>
 <4AD8C315.3070106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf van der Spek <olafvdspek@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51566 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbZJPT4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 15:56:00 -0400
Content-Disposition: inline
In-Reply-To: <4AD8C315.3070106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On 15-10-2009 10:59, Olaf van der Spek wrote:
> >> On Sat, Oct 10, 2009 at 3:01 PM, Olaf van der Spek <olafvdspek@gmail.com> wrote:
> >>> Hi,
> >>>
> >>> I'm forwarding Debian feature request #520668.
> >>>
> >>> Could syn cookies be enabled by default?
> > 
> > Hi,
> > 
> > Alas, I can only give you a hint: while waiting for a better response,
> > you could try to 'google' for some archives of this list; AFAICR a few
> > (?) months ago David Miller explained this first question at least.
> > (In short: they aren't up-to-date enough.)
> 
> It looks like my memory is exact only about dates ("?"! ;-). There was
> mainly David's opinion and some more in the thread (shared with lkml).
> Here is a link:
> http://lkml.indiana.edu/hypermail/linux/kernel/0807.3/0050.html

Hrm, strange.

The syncookie sysctl only has an effect on tcp options
once a listening sockets' syn queue is full. And even if you lose all
the tcp options -- without tcp_syncookies=1, the connection request
would have been discarded. So I do not really understand why they
shouldn't default to 1. I've sent patches for both points raised
(no warning about syn queue overflow if cookies are disabled,
 syncookies sysctl defaults to 0), lets see what happens :-)

