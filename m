From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols static
Date: Mon, 2 Jul 2012 10:53:03 +0400
Message-ID: <CAJmB2rDB6McXg=O_z-M3xFa0OrB5hkTWT=ZHM975GDTPvuGjtQ@mail.gmail.com>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1341211072.5269.0.camel@edumazet-glaptop>
	<1341211476.5269.2.camel@edumazet-glaptop>
	<1341211751.5269.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48478 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab2GBGxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:53:05 -0400
Received: by lbbgm6 with SMTP id gm6so7238471lbb.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:53:03 -0700 (PDT)
In-Reply-To: <1341211751.5269.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

>> > static DEFINE_SPINLOCK(flist_lock);
>>
>>
>> and of course commit 768f7c7c121e80f4 (6lowpan: add missing
>> spin_lock_init() ) must be reverted.
>
> You should validate this code with LOCKDEP
>
> lowpan_dellink() does a spin_lock(&flist_lock);
> while same lock can be taken by lowpan_fragment_timer_expired() from
> timer irq, -> deadlock.
>
> del_timer() probably needs a del_timer_sync() too
>

Thanks a lot for the hints!

Alex
