From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [GIT] Networking
Date: Thu, 25 Jun 2015 12:24:29 -0400
Message-ID: <CAP=VYLogXORmUN1bt1++ucmTOp=T-nJd2pve0-ufV+HQaCVy6Q@mail.gmail.com>
References: <20150624.063911.1220157256743743341.davem@davemloft.net> <CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35355 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbFYQZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 12:25:00 -0400
In-Reply-To: <CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2015 at 7:38 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:

[...]

>
> I'm getting *real* tired of that BUG_ON() shit. I realize that
> infiniband is a niche market, and those "commercial grade" niche
> markets are more-than-used-to crap code and horrible hacks, but this
> is still the kernel. We don't add random machine-killing debug checks
> when it is *so* simple to just do
>
>         if (WARN_ON_ONCE(..))
>                 return -EINVAL;
>
> instead.
>
> Killing the machine for idiotic things like that is truly offensive,
> and truly horrible horrible code. Why do I keep on having to tell
> people off for doing these things? Why do people keep thinking that
> debugging-by-killing-the-machine is a good idea?

Ingo figured this was an educational battle that we'd never win.

https://lkml.org/lkml/2014/5/21/490

I tend to agree, as unfortunate as that is.

Paul.
--

>
> Either that BUG_ON() cannot possibly happen, in which case it should
> damn well not exist in the first place. Or it's a valuable debug aid,
> in which case it should damn well not be a BUG_ON. You can't have it
> both ways.
>
> The next pointless BUG_ON() I see, I will start getting _really_
> unpleasant about.
>
> Doug, get rid of those things asap.
>
>                     Linus
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
