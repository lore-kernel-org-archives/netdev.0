From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 4 Sep 2010 11:27:39 -0400
Message-ID: <AANLkTik06=U-0r+4819pzNLZvs21UaWR+4uO6H1_he+=@mail.gmail.com>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	<8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	<AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
	<1283583095.2320.11.camel@edumazet-laptop>
	<AANLkTimC4z7mCKwyK8=LaacjTtZGEGN_BYsFMydQiwBk@mail.gmail.com>
	<1283608311.3402.30.camel@edumazet-laptop>
	<AANLkTik+T8Sv1tEmy4PU0O-dOeymJLEkEd9QOYy7ZJzC@mail.gmail.com>
	<1283610664.3402.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59008 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab0IDP1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 11:27:41 -0400
Received: by fxm13 with SMTP id 13so1824688fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 08:27:39 -0700 (PDT)
In-Reply-To: <1283610664.3402.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 4, 2010 at 10:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Nope. Because if each packet goes through two cpus instead of one before
> being queued to socket queue, you pay overhead and memory trafic between
> these cpus.

But if an interface is set in promisc-mode then why split the flows?
And if rps is not enabled(which by default it isn't) then everything
should just work as before.


>
> This is the reason why RPS is not automatically switched on. It might be
> slower on some workloads.
>
I'm now generating multi-flow traffic pattern and still the same.


Chetan
