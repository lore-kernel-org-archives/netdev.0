From: Florian Westphal <fw@strlen.de>
Subject: Re: net: cleanup_net is slow
Date: Mon, 24 Apr 2017 14:08:35 +0200
Message-ID: <20170424120835.GA20444@breakpoint.cc>
References: <CAAeHK+yJXMo8kr_p8iM_dicVGQCtwQhdk=rdE+9dNbsoghAb6Q@mail.gmail.com>
 <CANn89i+iYtPLGDZpt3qk_cA-dq+004B=1qjP0ZygY3oREskQYA@mail.gmail.com>
 <20170421192729.GA8853@breakpoint.cc>
 <20170421194515.GB8853@breakpoint.cc>
 <CAAeHK+zwsdzVrgwLccbXs7QUEsFkeTL13_AfNKMD1G2BkOr0eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+zwsdzVrgwLccbXs7QUEsFkeTL13_AfNKMD1G2BkOr0eg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Konovalov <andreyknvl@google.com> wrote:
> On Fri, Apr 21, 2017 at 9:45 PM, Florian Westphal <fw@strlen.de> wrote:
> > Florian Westphal <fw@strlen.de> wrote:
> >> Indeed.  Setting net.netfilter.nf_conntrack_default_on=0 cuts time
> >> cleanup time by 2/3 ...
> >>
> >> nf unregister is way too happy to issue synchronize_net(), I'll work on
> >> a fix.
> >
> > I'll test this patch as a start.  Maybe we can also leverage exit_batch
> > more on netfilter side.
> 
> Hi Florian,
> 
> Your patch improves fuzzing speed at least twice, which is a great start!

Great.  I'll try to push the patches i have to nf-next ASAP.
