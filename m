From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Mon, 28 Nov 2016 15:16:13 -0800
Message-ID: <1480374973.18162.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <1480359019.18162.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAeHK+wWVp46ej0tk5mDnOHpH5Ky0+HiH9_SUqGcT0iTppLaGw@mail.gmail.com>
         <CACT4Y+Yr6UJxXosjx2FO=KtxGr40X07_UBiscs1BP1s8cTaqAA@mail.gmail.com>
         <1480362459.18162.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480367152.18162.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480367886.18162.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161128213444.GA9858@breakpoint.cc>
         <1480371244.18162.91.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161128221923.GC9858@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128221923.GC9858@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-28 at 23:19 +0100, Florian Westphal wrote:

> It currently returns -EINVAL in cases where skb wasn't changed/altered
> (e.g. because it doesn't have a fragment header), so we should ACCEPT in
> that case.
> 

Maybe nf_ct_frag6_queue() should return direct NF_ codes then ...
