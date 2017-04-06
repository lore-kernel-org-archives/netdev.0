From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS when
 fail to transmit RST
Date: Thu, 6 Apr 2017 10:08:20 -0400
Message-ID: <CADVnQy=5GXBQzvDtbxQp-0ndJ1KphcxkY42mHsDPST0+sMGw2A@mail.gmail.com>
References: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com>
 <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com> <001301d2aede$e1e54f00$a5afed00$@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35218 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935160AbdDFOIx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:08:53 -0400
Received: by mail-oi0-f46.google.com with SMTP id f193so52415855oib.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 07:08:52 -0700 (PDT)
In-Reply-To: <001301d2aede$e1e54f00$a5afed00$@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 6, 2017 at 10:05 AM, Gao Feng <gfree.wind@foxmail.com> wrote:
> If so, we should increase the TCP_MIB_OUTRSTS too when fail to alloc skb.
> When machine is overloaded and mem is exhausted, it may fail to alloc skb.

Moving the increment of TCP_MIB_OUTRSTS to the top of
tcp_send_active_reset() sounds fine to me.

neal
