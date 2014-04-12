From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Fri, 11 Apr 2014 17:58:00 -0700
Message-ID: <20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:35942 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438AbaDLA6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 20:58:04 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so6065577pbc.37
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 17:58:03 -0700 (PDT)
In-Reply-To: <CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2014 17:45:53 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, Apr 11, 2014 at 2:04 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> > Iproute2 commands are supposed to be invertible.
> > If you take something as input, it should be displayed on output.
> 
> It's already there:
> 
>         } else if (sel && sel->flags&TC_U32_TERMINAL) {
>                 fprintf(f, "terminal flowid ??? ");
>         }

But it printing it like an error, not an known good option.
The ??? implies that somebody did something wrong.
