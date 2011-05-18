From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 13:58:14 +0200
Message-ID: <BANLkTi=_ob1iM4yB3m3NoiPccSYd8koABQ@mail.gmail.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	<1305704885.2983.4.camel@edumazet-laptop>
	<BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	<1305707358.2983.14.camel@edumazet-laptop>
	<4DD38B30.9090601@cn.fujitsu.com>
	<BANLkTikVxfxU2uW3AA--q8qt16og=HdDLg@mail.gmail.com>
	<1305718902.2991.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53785 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964Ab1ERL6P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 07:58:15 -0400
Received: by pvg12 with SMTP id 12so669827pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 04:58:14 -0700 (PDT)
In-Reply-To: <1305718902.2991.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mercredi 18 mai 2011 =E0 13:01 +0200, Jacek Luczak a =E9crit :
>
>> @Eric, if you will take a look into the code you might notice
>> that there are few places where list operations could be
>> optimised and the main question here is do we really care
>> to have the data ,,safe'' so that things like that won't popup.
>> The good example can be the set of _local_ functions.

There should be a vertical space here ...

>> Ahhh... and I'm aware of how tricky can be abuse of RCU.
>
> I took a quick look at existing rcu_read_lock() uses in sctp and did =
not
> find other problems [or optimizations if you prefer this point of vie=
w].
> Please elaborate.

=2E.. so that the last line does not have any connection with what I've
wrote above.

I get your point Eric so you don't really have to prove it - if you sti=
ll need.

-jacek
