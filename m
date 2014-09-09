From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/6] bonding: get rid of bond->lock
Date: Tue, 09 Sep 2014 21:49:06 +0200
Message-ID: <540F59B2.5080406@redhat.com>
References: <1410011971-24922-1-git-send-email-nikolay@redhat.com>	<20140909.115139.1465933020340882843.davem@davemloft.net> <20140909.115755.1617761218805940442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbaIITtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 15:49:14 -0400
In-Reply-To: <20140909.115755.1617761218805940442.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2014 08:57 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 09 Sep 2014 11:51:39 -0700 (PDT)
>=20
>> You are a brave person playing with bond locking, I must say :)
>>
>> Series applied, thanks.
>=20
> Sorry I had to revert, there is code referencing the bond->lock in
> the cxgb4 driver :-/
>=20
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function =A1cxgb4=
_inet6addr_handler=A2:
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4393:3: error: =A1str=
uct bonding=A2 has no member named =A1lock=A2
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4407:3: error: =A1str=
uct bonding=A2 has no member named =A1lock=A2
>=20
> Please test build with allmodconfig.
>=20
Wow, my bad! Sorry about that, I didn't expect it.
I will take a look and fix it in v2 + the allmodconfig test :-)

Thanks!
