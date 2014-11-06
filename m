From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Thu, 6 Nov 2014 10:05:41 -0800
Message-ID: <CAM_iQpWw4UMKZcdZfpp5D-tDfj954fbptyXJUzydgFCero6xNw@mail.gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	<1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
	<1415152068.1458.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:51990 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaKFSFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:05:42 -0500
Received: by mail-ob0-f177.google.com with SMTP id m8so1216976obr.36
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 10:05:42 -0800 (PST)
In-Reply-To: <1415152068.1458.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 5:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-11-04 at 17:25 -0800, Cong Wang wrote:
>
>> Seriously, think about why it should when it's just cleanup's, be practical.
>
> I seriously ask you to not do cleanups then.

Apparently you didn't say this when the following commits got accepted:

commit 436f7c206860729d543a457aca5887e52039a5f4
Author: Fabian Frederick <fabf@skynet.be>
Date:   Tue Nov 4 20:52:14 2014 +0100

    igmp: remove camel case definitions

    use standard uppercase for definitions

    Signed-off-by: Fabian Frederick <fabf@skynet.be>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit c18450a52a10a5c4cea3dc426c40447a7152290f
Author: Fabian Frederick <fabf@skynet.be>
Date:   Tue Nov 4 20:48:41 2014 +0100

    udp: remove else after return

commit aa1f731e52807077e9e13a86c0cad12d442c8fd4
Author: Fabian Frederick <fabf@skynet.be>
Date:   Tue Nov 4 20:44:04 2014 +0100

    inet: frags: remove inline on static in c file

    remove __inline__ / inline and let compiler decide what to do
    with static functions

    Inspired-by: "David S. Miller" <davem@davemloft.net>
    Signed-off-by: Fabian Frederick <fabf@skynet.be>
    Signed-off-by: David S. Miller <davem@davemloft.net>

>
> Some people are working adding real stuff here, this code changing every
> month is slowing them a lot.
>

Who works on what? Does he/she at least announce it on netdev?
(If you meant John, I already waited for his rcu stuffs in the last
merge window,
I assumed his works is almost done therefore sent this patchset.)

Since when it becomes a rule that we should yield to something not merged,
not even announced? If so, why not adding it to netdev-FAQ?
