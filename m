From: David Miller <davem@davemloft.net>
Subject: Re: sendmmsg: put_user vs __put_user
Date: Sat, 31 Mar 2012 17:27:10 -0400 (EDT)
Message-ID: <20120331.172710.540592519617177028.davem@davemloft.net>
References: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
	<20120330.205120.2221145622131588797.davem@davemloft.net>
	<CAOPLpQewA-AduBudgH5FK6Kz_=nHv6eFhGD29TkAosPTdP4ZHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: drepper@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOPLpQewA-AduBudgH5FK6Kz_=nHv6eFhGD29TkAosPTdP4ZHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ulrich Drepper <drepper@gmail.com>
Date: Sat, 31 Mar 2012 08:30:25 -0400

> On Fri, Mar 30, 2012 at 20:51, David Miller <davem@davemloft.net> wro=
te:
>> Compat processes are not able to generate virtual addresses anywhere
>> near the range where the kernel resides, so the address range
>> verification done by put_user() is completely superfluous and
>> therefore not necessary. =A0The normal exception handling done by th=
e
>> access is completely sufficient.
>=20
> I was more thinking about the effects of might_fault() then additiona=
l tests.

This is very clearly in a context where locks are not held and sleeping
would be fine, so I don't see any value in that either.
