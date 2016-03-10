From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: net: use-after-free in recvmmsg
Date: Thu, 10 Mar 2016 16:31:07 -0300
Message-ID: <20160310193107.GA2976@redhat.com>
References: <CACT4Y+YUobBGeFiq5d-==TBB7F2am+wjH6CKVz0uCvw4KuM1dg@mail.gmail.com>
 <20160122211644.GC2470@redhat.com>
 <CACT4Y+ZBNZGEWAe-iXeUO=PwNb39T60Sa0hYTrY-mykYuPZgYQ@mail.gmail.com>
 <20160126193056.GA3986@redhat.com>
 <CACT4Y+ZwoP73BEEeNeZwYj_c098mkU4WJ4z47twT7TmjStzEPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbcCJTbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 14:31:10 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZwoP73BEEeNeZwYj_c098mkU4WJ4z47twT7TmjStzEPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Mar 10, 2016 at 07:35:57PM +0100, Dmitry Vyukov escreveu:
> On Tue, Jan 26, 2016 at 8:30 PM, Arnaldo Carvalho de Melo
> <acme@redhat.com> wrote:
> > Em Tue, Jan 26, 2016 at 08:27:48PM +0100, Dmitry Vyukov escreveu:
> >> On Fri, Jan 22, 2016 at 10:16 PM, Arnaldo Carvalho de Melo <acme@redhat.com> wrote:
> >> > Em Fri, Jan 22, 2016 at 09:39:53PM +0100, Dmitry Vyukov escreveu:
> >> >> I am on commit 30f05309bde49295e02e45c7e615f73aa4e0ccc2 (Jan 20).
> >> >> Seems to be added in commit a2e2725541fad72416326798c2d7fa4dafb7d337
> >> >> (Oct 2009).
> >> >
> >> > Maybe this helps? Compile testing now...
> >>
> >>
> >> I don't have a reliable reproducer, so can't test it per se.
> >> I will integrate this patch tomorrow and restart fuzzer with it.
> >
> > Thanks a lot!
> 
> Hi Arnaldo,
> 
> I am running with that patch since then, and did not see the bug.
> Please mail it as a proper patch.

Thanks, and I'll add a:

Reported-and-Tested-by: Dmitry Vyukov <dvyukov@google.com>

Ok?

- Arnaldo
