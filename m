From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Mon, 22 Jun 2015 14:36:11 +0200
Message-ID: <87lhfbly2s.fsf@gmail.com>
References: <87pp4vw3ep.fsf@gmail.com>
	<20150621.095400.890337700038231482.davem@davemloft.net>
	<87y4jdc58w.fsf@gmail.com> <1434972453.4568.8.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolai Stange <nicstange@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn@linux-pingi.de, Chen Gang <gang.chen.5i5j@gmail.com>,
	Ralf Baechle <ralf@linux-mips.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35209 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbbFVMgR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 08:36:17 -0400
In-Reply-To: <1434972453.4568.8.camel@chaos.site> (Jean Delvare's message of
	"Mon, 22 Jun 2015 13:27:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare <jdelvare@suse.de> writes:
> Le Sunday 21 June 2015 =C3=A0 19:59 +0200, Nicolai Stange a =C3=A9cri=
t :
>> David Miller <davem@davemloft.net> writes:
>>> Applied, but we're long overdue for an across-the-board-available
>>> endianness Kconfig option that can flat out be used in these situat=
ions.
>>> The current way this is handled is at best, a mess.
>>=20
>> Regarding the general Kconfig endianess symbol, I will do another pa=
tch
>> based on the information of
>>   git grep '_endian\.h' -- arch/
>> and supply every arch with either of CONFIG_CPU_{LITTLE,BIG}_ENDIAN =
if
>> lacking.
>
> Note that Chen Gang (Cc'd) attempted the same almost a year ago:
> http://patchwork.linux-mips.org/patch/7540/
> then:
> http://marc.info/?t=3D140958656400002&r=3D1&w=3D2
>
> The idea was great IMHO but it did not work out, and I can't remember
> why.

Thank you very much for this pointer, Jean!  I've read through these
threads and to summarize, some arch maintainers' main point against tha=
t
patchset is that (recent) drivers should generally support both, LE and
BE.

It is interesting to note that Chen Gang had already addressed the very
same issue (Hisax NetJet driver) by the far more general approach
proposed by David Miller here, namely by introducing an
"across-the-board-available endianess Kconfig option".

So unless you really want to have such an option and ping me, I will no=
t
do another patch in the mood of Chen Gang's original one.
