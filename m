From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Pv-drivers] rps and pvdrivers
Date: Sat, 04 Sep 2010 09:00:52 +0200
Message-ID: <1283583652.3402.2.camel@edumazet-laptop>
References: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
	 <8B1F619C9F5F454E81D90D3C161698D70337A49A5A@EXCH-MBX-3.vmware.com>
	 <AANLkTi=o8GYdLyY8EzfRno39O2kUSh3wSp9raZCUp_Zz@mail.gmail.com>
	 <1283583095.2320.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bhavesh Davda <bhavesh@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Chetan Loke <chetanloke@gmail.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63995 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab0IDHA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 03:00:57 -0400
Received: by fxm13 with SMTP id 13so1687016fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 00:00:56 -0700 (PDT)
In-Reply-To: <1283583095.2320.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 08:51 +0200, Eric Dumazet a =C3=A9cr=
it :
> >=20
>=20
> Reproduce what exactly ?=20
>=20
> I dont understand what the problem is, reading your description.
>=20
> RPS is not automatically switched on, you have to configure it.
>=20
> echo ffff >/sys/class/net/eth0/queues/rx-0/rps_cpus
>=20
> Same for RFS if you prefer to use RFS
>=20
> echo 16384 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt
>=20

And, before you try this, you probably also need

echo 16384 >/proc/sys/net/core/rps_sock_flow_entries

Tom, I believe you were about to add RPS documentation in
Documentation/ ?


> If you receive a flood, your cpu stay in NAPI mode, and no hardware
> interrupt is received while you process xxx.xxx packets per second.
>=20
>=20


