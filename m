From: Myungho Jung <mhjungk@gmail.com>
Subject: Re: [PATCH v2] net: core: Prevent from dereferencing null pointer
 when
Date: Mon, 24 Apr 2017 18:36:57 -0700
Message-ID: <20170425013657.GA11509@fqdn.specialj.com>
References: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
 <20170424.120235.438297438450788048.davem@davemloft.net>
 <20170425010052.GA8717@fqdn.specialj.com>
 <CANn89iL1n67fkZm0ZL0zN0_AL_uWZDKZXY3mOrn0H96vZTX7zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35831 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965820AbdDYBhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:37:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id a188so7110246pfa.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 18:37:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANn89iL1n67fkZm0ZL0zN0_AL_uWZDKZXY3mOrn0H96vZTX7zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 06:10:32PM -0700, Eric Dumazet wrote:
> On Mon, Apr 24, 2017 at 6:00 PM, Myungho Jung <mhjungk@gmail.com> wrote:
> > On Mon, Apr 24, 2017 at 12:02:35PM -0400, David Miller wrote:
> >> From: Myungho Jung <mhjungk@gmail.com>
> >> Date: Thu, 20 Apr 2017 16:59:20 -0700
> >>
> >> > Added NULL check to make __dev_kfree_skb_irq consistent with kfree
> >> > family of functions.
> >> >
> >> > Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
> >> >
> >> > Signed-off-by: Myungho Jung <mhjungk@gmail.com>
> >> > ---
> >> > Changes in v2:
> >> >  - Correct category in subject
> >>
> >> This subject line is an incomplete sentence.
> >>
> >> This patch prevents dereferenccing a null pointer when "what"?
> >
> > As it was reported on bugzilla, it would happen when plugging p54 usb device
> > to RPi2. But, i'm not 100% sure that this patch will resolve the issue because
> > the reporter didn't try my patch yet and I don't have the device to test.
> >
> > And there might be some other places calling the function without checking
> > null pointer. The thing is that only the function don't check null among
> > kfree functions. So, I just hope this patch will prevent potential oops
> > issues.
> 
> Okay, but your patch title was : "net: core: Prevent from
> dereferencing null pointer when"
> 
> "when" is usually followed by other words.

Oh, sorry that was typo. I'll remove "when" from subject.

Thanks,
Myungho
