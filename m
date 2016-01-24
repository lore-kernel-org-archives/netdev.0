From: Eric Dumazet <edumazet@google.com>
Subject: Re: struct pid memory leak
Date: Sun, 24 Jan 2016 13:11:22 -0800
Message-ID: <CANn89iKSm5sThUA0V6-jjWAwqM=+8QQEjS_pR2GUzsXtkui3sg@mail.gmail.com>
References: <CACT4Y+bZTpitMQOCyPcf4kKaXwghhEe3hmT=FtkrD3toZgoxxQ@mail.gmail.com>
	<1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160123180010.GB1609@1wt.eu>
	<CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com>
	<20160123184007.GE1609@1wt.eu>
	<CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com>
	<20160124021145.GA12367@1wt.eu>
	<20160124023824.GA13942@1wt.eu>
	<CANn89i+KfDVX8SO3mLnh8naXGb3WiM80=aBuhQKBVstZyfS_xg@mail.gmail.com>
	<20160124030412.GA13949@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Hocko <mhocko@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38381 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbcAXVLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 16:11:23 -0500
Received: by mail-wm0-f45.google.com with SMTP id b14so52830263wmb.1
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2016 13:11:23 -0800 (PST)
In-Reply-To: <20160124030412.GA13949@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 7:04 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Sat, Jan 23, 2016 at 06:50:11PM -0800, Eric Dumazet wrote:
>> On Sat, Jan 23, 2016 at 6:38 PM, Willy Tarreau <w@1wt.eu> wrote:
>> > On Sun, Jan 24, 2016 at 03:11:45AM +0100, Willy Tarreau wrote:
>> >> It doesn't report this on 3.10.
>> >
>> > To be more precise, kmemleak reports the issue on 3.13 and not on 3.12.
>> > I'm not sure if it's reliable enough to run a bisect though.
>> >
>> > Willy
>> >
>>
>> I have the leak on linux-3.11.
>>
>> I believe even linux-3.3 gets the leak, although I had to wait about
>> one hour to be confident the leak was there.
>
> OK so I'm stopping my bisect. It's possible it's affected with some option
> which changed along the various "make oldconfig" at each step. Thanks for
> letting me know.

Bug was added in 2.6.38 . I am testing a fix and will send it today.
