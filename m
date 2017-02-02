From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Thu, 02 Feb 2017 05:40:12 -0800
Message-ID: <1486042812.13103.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
         <CANn89iKSSmaSHJGfgR4AkRgMRfYx+52XXjWsxZovUzorpneL=g@mail.gmail.com>
         <CACT4Y+Yw8_ZkjajkGdZ=71Mo83O+K=NJTZO+cM-+8UzTzHC-=A@mail.gmail.com>
         <1486038029.13103.17.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+Z8uSWJaW+QXSOr7dCo5fSNrMu6fHxPcDBxL08qQUvRMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Z8uSWJaW+QXSOr7dCo5fSNrMu6fHxPcDBxL08qQUvRMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-02-02 at 13:59 +0100, Dmitry Vyukov wrote:

> 
> Right, I can confirm that this is not happening on net-next tip
> (62e13097c46c69dbd7544ab2cd585ccf48f360a4).
> I reproduced it on a random month old commit on net-next, though
> (23a8ed4a624324dc696c328f09bd502c4a3816f0). Let's consider that this
> is accidentally fixed by something in that range.

This also might depend on the .config 

I tried 23a8ed4a624324dc696c328f09bd502c4a3816f0 and could not trigger
the warning .

Thanks.
