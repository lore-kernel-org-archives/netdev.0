From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Thu, 08 Jul 2010 21:34:20 -0700 (PDT)
Message-ID: <20100708.213420.112614033.davem@davemloft.net>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
	<AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	jengelh@medozas.de
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 Jul 2010 18:34:25 -0700

> On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote=
:
>>
>> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
16187
>> Subject =A0 =A0 =A0 =A0 : Carrier detection failed in dhcpcd when li=
nk is up
>> Submitter =A0 =A0 =A0 : Christian Casteyde <casteyde.christian@free.=
fr>
>> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-12 15:15 (27 days old)
>> First-Bad-Commit: http://git.kernel.org/linus/10708f37ae729baba9b67b=
d134c3720709d4ae62
>> Handled-By =A0 =A0 =A0: Andrew Morton <akpm@linux-foundation.org>
>=20
> David? This bisects to a networking commit. Doesn't look sensible, bu=
t
> what do I know?

My suspicion is that dhcpd uses netlink to dump the info of the
available links, and due to some bug gets confused with the new 64-bit
statistic netlink attribute being there now.

That shouldn't happen, applications should just ignore the attributes
which they don't understand.

I'll try to find a second to have a look at this.
