From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Wed, 9 Dec 2015 13:03:56 -0200
Message-ID: <20151209150356.GA3886@mrl.redhat.com>
References: <CACT4Y+ZhRG-LCdEoF=WusYVUj8gnm16663GcgJ=ztu0QC6r0vg@mail.gmail.com>
 <20151207185218.GB22989@mrl.redhat.com>
 <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com>
 <5665EE26.3000706@gmail.com>
 <5665F17B.5030908@gmail.com>
 <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
 <20151208174039.GB22987@mrl.redhat.com>
 <CACT4Y+b1OEE9NqN3J5574iN7t8NEi9jPc2Hxoj6AMHZKjCJ-mg@mail.gmail.com>
 <CACT4Y+YYbC53awV4eiDAwjJO=WHYGv3Og3XDh-gTFB1q_w0YXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbbLIPEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 10:04:01 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+YYbC53awV4eiDAwjJO=WHYGv3Og3XDh-gTFB1q_w0YXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 03:41:29PM +0100, Dmitry Vyukov wrote:
> On Tue, Dec 8, 2015 at 8:22 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > On Tue, Dec 8, 2015 at 6:40 PM, Marcelo Ricardo Leitner
> > <marcelo.leitner@gmail.com> wrote:
...
> >> The patches were combined already, but this last pick by Vlad is just
> >> not yet patched. It's not necessary for your testing and I didn't want
> >> to interrupt it in case you were already testing it.
> >>
> >> You can use my last patch here, from 2 emails ago, the one which
> >> contains this line:
> >> -       case SCTP_DISPOSITION_ABORT:
> >
> >
> > You are right. I missed that they are combined. Testing with it now.
> 
> 
> 
> 
> Use-after-free still happens.
> I am on commit aa53685549a2cfb5f175b0c4a20bc9aa1e5a1b85 (Dec 8) plus
> the following sctp-related changes:

Changes are fine.  Ugh. Ok, I'll try your new reproducer here.

  Marcelo
