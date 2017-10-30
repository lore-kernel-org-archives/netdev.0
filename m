From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN: use-after-free Write in detach_if_pending
Date: Mon, 30 Oct 2017 10:30:29 -0700
Message-ID: <1509384629.11887.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <089e0825d424dfce58055c84205f@google.com>
         <alpine.DEB.2.20.1710291327310.1922@nanos>
         <1509282075.11887.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+YrZzmn9N5jXH-8+T9P+kbyjstDFAeNooaPdrBbzepH4w@mail.gmail.com>
         <1509381386.11887.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+bppGVyDVCYa0eL6hG5StSCn35eqH+fjM1LOBu+ktD9rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        syzbot
        <bot+c0733f3aab92fc116dc1d10d8a25f5bf1f739eff@syzkaller.appspotmail.com>,
        John Stultz <john.stultz@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>, sboyd@codeaurora.org,
        syzkaller-bugs@googlegroups.com, netdev <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bppGVyDVCYa0eL6hG5StSCn35eqH+fjM1LOBu+ktD9rQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-30 at 18:06 +0100, Dmitry Vyukov wrote:

> Yes, but hashes in random trees also don't tell much. A tree can be
> rebased so the hash will be lost. It can be a tree unknown to the
> system. Even if we find the commit by hash, in order to match it
> against other trees we will have to use the title anyway (or are there
> better options?), so using hashes becomes pointless.

We do not send hashes on random trees, but official SHA1 in David Miller
trees. They will be the same SHA1 in official Linus Torvalds tree.

Really, you make our life more difficult by pretending that hashes are
not the proper way.

They are reasons we use Fixes: tags all over the places, they are unique
in Linus tree.

Since syzbot gives a SHA1 itself, it must be using a tree, right ?

So a SHA1 that is guaranteed to enter the same tree is correct.

Please fix your bot.
