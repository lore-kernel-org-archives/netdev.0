From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 11:47:39 -0800
Message-ID: <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
         <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
         <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35786 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbcK1Tsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:48:42 -0500
In-Reply-To: <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-28 at 20:34 +0100, Dmitry Vyukov wrote:
> On Mon, Nov 28, 2016 at 8:04 PM, 'Andrey Konovalov' via syzkaller

> > Hi Eric,
> >
> > As far as I can see, skb_network_offset() becomes negative after
> > pskb_pull(skb, (u8 *) (fhdr + 1) - skb->data) in nf_ct_frag6_queue().
> > At least I'm able to detect that with a BUG_ON().
> >
> > Also it seems that the issue is only reproducible (at least with the
> > poc I provided) for a short time after boot.
> 
> 
> Eric,
> 
> Is it enough to debug? Or maybe Andrey can trace some values for you.

Well, now we are talking, if you tell me how many modules you load, it
might help ;)

nf_ct_frag6_queue is nowhere to be seen in my kernels, that might
explain why I could not reproduce the bug.

Let me try ;)
