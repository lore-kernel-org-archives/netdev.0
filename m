From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] atheros/atlx: use SET_ETHTOOL_OPS directly
Date: Fri, 21 Mar 2014 09:41:46 +0800
Message-ID: <532B98DA.10902@huawei.com>
References: <532965C3.6090706@huawei.com>	<20140320.160701.546438379437520632.davem@davemloft.net> <20140320.161705.764874095331082303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jcliburn@gmail.com>, <chris.snook@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45061 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759885AbaCUBmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:42:37 -0400
In-Reply-To: <20140320.161705.764874095331082303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/21 4:17, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 20 Mar 2014 16:07:01 -0400 (EDT)
>=20
>> From: Wang Weidong <wangweidong1@huawei.com>
>> Date: Wed, 19 Mar 2014 17:39:15 +0800
>>
>>> As commit a6e28b34205b("staging/et131x: use SET_ETHTOOL_OPS
>>> directly"), using a wrapper around SET_ETHTOOL_OPS macro is
>>> not actually required, remove and use SET_ETHTOOL_OPS directly.
>>>
>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>
>> Applied, thank you.
>=20
> I reverted, you did not ever build test this:
>=20
> drivers/net/ethernet/atheros/atlx/atl2.c: In function =A1atl2_probe=A2=
:
> drivers/net/ethernet/atheros/atlx/atl2.c:1398:2: error: =A1atl2_ethto=
ol_ops=A2 undeclared (first use in this function)
> drivers/net/ethernet/atheros/atlx/atl2.c:1398:2: note: each undeclare=
d identifier is reported only once for each function it appears in
> make[1]: *** [drivers/net/ethernet/atheros/atlx/atl2.o] Error 1
> make: *** [drivers/net/ethernet/atheros/atlx/atl2.o] Error 2
>=20
> If you do not even have the time to do a test build, then I do not
> have the time to review and apply your patches.
>
Hi David,
=20
So sorry for your time. I built all the kernel at first time, and this =
error
log was hidden, although, I should build it in the drivers/ and ensured=
 it OK,
It is my mistake.

I will fix it.

Regards
Wang
