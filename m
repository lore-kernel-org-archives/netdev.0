From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 3/3] net: reserve ports for applications using
 fixed port numbers
Date: Sat, 20 Feb 2010 16:00:46 +0800
Message-ID: <4B7F96AE.1010102@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com>	 <1266271241-6293-4-git-send-email-opurdila@ixiacom.com>	 <4B7A6740.1000701@redhat.com> <201002161306.29708.opurdila@ixiacom.com>	 <4B7A9852.5020105@redhat.com> <1266326425.3045.53.camel@edumazet-laptop>	 <4B7C159A.3060603@redhat.com> <1266424768.3075.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621Ab0BTH51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 02:57:27 -0500
In-Reply-To: <1266424768.3075.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 18 f=C3=A9vrier 2010 =C3=A0 00:13 +0800, Cong Wang a =C3=A9c=
rit :
>=20
>> I don't think so, if you want to avoid race condition, you just need=
 to
>> write the reserved ports before any networking application starts, I=
OW,
>> as early as possible during boot.
>>
>=20
> Sure, but I was thinking retrieving the list of reserved port by a
> database query, using network :)
>=20
> Anyway, I just feel your argument is not applicable.
>=20
> Our kernel is capable of doing an intersection for us, we dont need
> to forbid user to mark a port as 'reserved' if this port is already
> blacklisted by another mechanism (for example, if this port is alread=
y
> in use)
>=20

Oh, I see your points.

But this still could make people confused, like me. I think we'd better
document this.

Thanks.
