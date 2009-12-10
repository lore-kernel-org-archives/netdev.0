From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 20:31:52 +0100
Message-ID: <4B214CA8.7010902@gmail.com>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com> <4B207840.7080603@gmail.com> <97949e3e0912100950u51f627c9r515d9b69a02430f4@mail.gmail.com> <alpine.LSU.2.01.0912101953360.23791@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Laurent Chavey <chavey@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.0912101953360.23791@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 10/12/2009 19:53, Jan Engelhardt a =E9crit :
>=20
> On Donnerstag 2009-12-10 18:50, Laurent Chavey wrote:
>>
>> good point.  I  agree with the need for the exception, I would just
>> like it to be more explicit in the code itself (like a turn off
>> check around that particular statement) so we do not have to scrub
>> thru the compiler output to filter out good / bad warning. question:
>>  why do we not force the timestamp in the skb before going thru the
>> chain ?
>=20
> Because it is probably too expensive to do, unless you employ
> things like xt_time?

Right. On some platforms, timestamps are quite expensive (say, a fracti=
on=20
of one micro second to get one of them), we try to avoid them as much a=
s possible.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
