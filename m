From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in ip6_xmit
Date: Mon, 7 Dec 2015 07:22:49 -0800
Message-ID: <CANn89i+BRPvDgSFUZGS5iq63C_OrNFK_86pNT0MUEw4OqkqYJQ@mail.gmail.com>
References: <CACT4Y+aJdFhzX-QKQR3ZNZ=MHPoNQdoS6arFaVn0c4GgUzfb0g@mail.gmail.com>
	<1449498980.25029.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<1449499144.25029.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+bGbGT4jA1XKG3_2e8eQgC=oD79FkXEiyELg2UcMZMqMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bGbGT4jA1XKG3_2e8eQgC=oD79FkXEiyELg2UcMZMqMA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 7, 2015 at 6:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Yes, seems to be fixed on master of
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git. Just
> can't pull in all fixes from all trees. Sorry.
> When will it be merged into Linus tree?
>

As I said, they are already in Linus tree, part of linux-4.4-rc4,
released yesterday.

I would like to remind you lkml and netdev have thousands of subscribers,
so please do not flood them with duplicates, especially considering
you were CC on all
the patches I cooked to address your original report.

So you knew patches were on their way.

commit 071f5d105a0ae93aeb02197c4ee3557e8cc57a21
Merge: 2873d32ff493 e3c9b1ef78eb
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Dec 3 16:02:46 2015 -0800

    Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
