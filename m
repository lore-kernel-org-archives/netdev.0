From: Meelis Roos <mroos@linux.ee>
Subject: Re: 4.9-rc7: (forcedeth?) BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 23:55:12 +0200 (EET)
Message-ID: <alpine.LRH.2.20.1611292352270.31348@math.ut.ee>
References: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee> <CAADWXX8GM5Xdf1Of09ABXEB8eb=eVqPjHTaT7ZzcStnX8=cO_A@mail.gmail.com> <alpine.LRH.2.20.1611292309490.31348@math.ut.ee> <1480449495.18162.152.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA+55aFwUFPLbcqpoccKXHsGj_80ANaMwCSgwTUqgxMFmNRHkaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwUFPLbcqpoccKXHsGj_80ANaMwCSgwTUqgxMFmNRHkaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Nov 29, 2016 11:58 AM, "Eric Dumazet" <eric.dumazet@gmail.com> wrote:
> >
> > nv_do_nic_poll() is simply buggy and needs a fix.
> >
> > synchronize_irq() can sleep.
> 
> Yes, but why did it start showing up now? None of this has changed as far as I can see?

Found one thing that changed - compiler from 6.2.0-9 to 6.2.1-5 and 
binutils too in debian unstable (explicitly upgraded to get fix to the 
binutils bug that broke 64-bit kernels).

> Is it just timing and the transmit queue being busy? Perhaps due to the sheer size of messages? Meelis does seem to have a ton of debugging enabled..

Well, the dmesg is not too verbose but when I debugged some earlier 
problem, netconsole and many other debugging options were left on.

-- 
Meelis Roos (mroos@linux.ee)
