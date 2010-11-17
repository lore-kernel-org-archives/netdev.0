From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Tue, 16 Nov 2010 20:12:03 -0800
Message-ID: <4CE35613.8090307@intel.com>
References: <1289497978.17691.1582.camel@edumazet-laptop>	 <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>	 <1289504565.17691.1710.camel@edumazet-laptop>	 <20101116.112454.179916339.davem@davemloft.net> <1289937251.2732.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9397 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab0KQEMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 23:12:15 -0500
In-Reply-To: <1289937251.2732.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2010 11:54 AM, Eric Dumazet wrote:
> Le mardi 16 novembre 2010 =C3=A0 11:24 -0800, David Miller a =C3=A9cr=
it :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 11 Nov 2010 20:42:45 +0100
>>
>>> [PATCH] vlan: remove ndo_select_queue() logic
>>>
>>> Now vlan are lockless, we dont need special ndo_select_queue() logi=
c.
>>> dev_pick_tx() will do the multiqueue stuff on the real device trans=
mit.
>>>
>>> Suggested-by: Jesse Gross <jesse@nicira.com>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> Also applied, but again there were conflicts I had to resolve,
>> please check that I got it right.
>>
>=20
> Both patches seem fine to me.
>=20
> I am going to test them.
>=20
> Thanks !
>=20
>=20

Everything seems in order as far as I can tell. I've had io running ove=
r 50 VLANs for a few hours now.=20

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

