From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 13:41:42 +0200
Message-ID: <1305718902.2991.3.camel@edumazet-laptop>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
	 <1305704885.2983.4.camel@edumazet-laptop>
	 <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com>
	 <1305707358.2983.14.camel@edumazet-laptop>
	 <4DD38B30.9090601@cn.fujitsu.com>
	 <BANLkTikVxfxU2uW3AA--q8qt16og=HdDLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58810 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932815Ab1ERLlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 07:41:45 -0400
Received: by fxm17 with SMTP id 17so1118088fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 04:41:44 -0700 (PDT)
In-Reply-To: <BANLkTikVxfxU2uW3AA--q8qt16og=HdDLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 13:01 +0200, Jacek Luczak a =C3=A9crit :

> @Eric, if you will take a look into the code you might notice
> that there are few places where list operations could be
> optimised and the main question here is do we really care
> to have the data ,,safe'' so that things like that won't popup.
> The good example can be the set of _local_ functions.
> Ahhh... and I'm aware of how tricky can be abuse of RCU.

I took a quick look at existing rcu_read_lock() uses in sctp and did no=
t
find other problems [or optimizations if you prefer this point of view]=
=2E
Please elaborate.



