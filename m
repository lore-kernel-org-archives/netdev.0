From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] core: adjust checks for calling skb_copy_bits in skb_try_coalesce
Date: Thu, 20 Sep 2012 13:57:00 +0800
Message-ID: <CAJFZqHz5Ny8kbXk4arj-CEfQs+r28oGUQChNJ+0nSOTTg=c82A@mail.gmail.com>
References: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
	<1348118417.31352.52.camel@edumazet-glaptop>
	<CAJFZqHzTEwgJaKjvNLW3yYbMLUu0xm8tHwQ2e_TZJNdiTKOTFw@mail.gmail.com>
	<1348120438.31352.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:42758 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab2ITF5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:57:01 -0400
Received: by oago6 with SMTP id o6so1823162oag.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 22:57:00 -0700 (PDT)
In-Reply-To: <1348120438.31352.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Did you read skb_tailroom(to) definition by any chance ?
>
> static inline int skb_tailroom(const struct sk_buff *skb)
> {
>         return skb_is_nonlinear(skb) ? 0 : skb->end - skb->tail;
> }
>
> Current code is fine, because if @to is linear, its ... linear.
>
>
>

I am wrong, thanks.
