From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] ip_gre: fix fallback tunnel setup
Date: Thu, 28 Oct 2010 23:29:10 +0400
Message-ID: <4CC9CF06.1090806@parallels.com>
References: <1288283634.11523.20.camel@edumazet-laptop>	 <20101028.102917.246527148.davem@davemloft.net>	 <1288291138.2711.0.camel@edumazet-laptop>	 <20101028.114102.112602886.davem@davemloft.net>	 <1288291679.2711.1.camel@edumazet-laptop> <1288293079.2711.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46924 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322Ab0J1T3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 15:29:19 -0400
In-Reply-To: <1288293079.2711.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2010 11:11 PM, Eric Dumazet wrote:
> Le jeudi 28 octobre 2010 =C3=A0 20:47 +0200, Eric Dumazet a =C3=A9cri=
t :
>> Le jeudi 28 octobre 2010 =C3=A0 11:41 -0700, David Miller a =C3=A9cr=
it :
>>> I am still able to revert this I think without screwing up
>>> publicly visible history, so I will double check and do the
>>> revert if I can.
>>
>> Cool, I'll provide a patch in a couple of minutes, when tested.
>>
>=20
> I believe the right fix is this one, Pavel what do you think ?

Indeed. I missed the fact, that the gre driver uses ndo_init for
all devices including the fb one :(

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> With your patch, we allocate the per_cpu data twice for the fallback
> tunnel, thus leaking memory.

Yup...

> Thanks
