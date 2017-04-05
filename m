From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: list double add warning in sctp_endpoint_add_asoc
Date: Wed, 5 Apr 2017 11:22:05 -0300
Message-ID: <20170405142205.GD911@localhost.localdomain>
References: <CAAeHK+zwbeT=jBRRSf2KYXWM=eUZAEe5QHvKPYGG5qWh6A0JGQ@mail.gmail.com>
 <CADvbK_f1FEGRnucuMkQT6RKm0G1tKcfHyj=-GqxgzQ4iQoBLCg@mail.gmail.com>
 <20170404211454.GA911@localhost.localdomain>
 <CAAeHK+xQxcQB92NK5-xBtd2rWQRGWPv29G5jePva2c2sTg248Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754661AbdDEOWM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 10:22:12 -0400
Content-Disposition: inline
In-Reply-To: <CAAeHK+xQxcQB92NK5-xBtd2rWQRGWPv29G5jePva2c2sTg248Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 04:02:44PM +0200, Andrey Konovalov wrote:
> On Tue, Apr 4, 2017 at 11:14 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > On Wed, Apr 05, 2017 at 01:29:19AM +0800, Xin Long wrote:
> >> On Tue, Apr 4, 2017 at 9:28 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >> > Hi,
> >> >
> >> > I've got the following error report while fuzzing the kernel with syzkaller.
> >> >
> >> > On commit a71c9a1c779f2499fb2afc0553e543f18aff6edf (4.11-rc5).
> >> >
> >> > A reproducer and .config are attached.
> >> The script is pretty hard to reproduce the issue in my env.
> >
> > I didn't try running it but I also found the reproducer very complicated
> > to follow. Do you have any plans on having some PoC optimizer, so we can
> > have a more readable code?
> > strace is handy for filtering the noise, yes, but sometimes it doesn't
> > cut it.
> 
> We do have some plans (like to remote all those unnecessary helper
> functions), but it's probably not going to become much better.
> 
> You mostly only need to look at the thr() function to understand
> what's going on.

Okay.

> 
> What I sometimes do is run each of the switch cases under strace
> separately to understand what each of them do.
> 
> I've also attached a program in syzkaller format.
> You can take a look at it, if you find it useful, I can start
> attaching them for subsequent reports.

Comparing it to thr() they look very close, at least for this one.
But when you cannot extract a reproducer, it will certainly help.

Thanks,
Marcelo
