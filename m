From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: define __packed for the userspace code
Date: Sun, 22 Aug 2010 21:47:06 +0800
Message-ID: <AANLkTiktOcAvAxcXUxh+4jKh0nBmYCf0OVG0wqRNMb9T@mail.gmail.com>
References: <1282475544-24708-1-git-send-email-xiaosuo@gmail.com>
 <AANLkTin1BOgHBc4sTwFAmQhKFNvZ+90herc4Dsh9P8y2@mail.gmail.com> <201008221507.42023.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab0HVNr1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 09:47:27 -0400
In-Reply-To: <201008221507.42023.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 22, 2010 at 9:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Sunday 22 August 2010 13:23:42 Changli Gao wrote:
>> On Sun, Aug 22, 2010 at 7:12 PM, Changli Gao <xiaosuo@gmail.com> wro=
te:
>> > This commit
>> >
>> > =A0commit bc10502dba37d3b210efd9f3867212298f13b78e
>> > =A0Author: Eric Dumazet <eric.dumazet@gmail.com>
>> > =A0Date: =A0 Thu Jun 3 03:21:52 2010 -0700
>> >
>> > =A0 =A0net: use __packed annotation
>> >
>> > makes use of __packed in the userspace code. So we'd better define=
 __packed
>> > for the userspace code too.
>> >
>>
>> Oh, sorry. This patch can't work as include/linux/compiler.h isn't
>> exported to the userspace. But where should we define __packed for t=
he
>> userspace code? include/linux/types.h?
>
> I would try to avoid making those structures packed to start with.
> From what I can see, they structures annotated in the above commit
> mostly don't even require explicit packing because they are already
> packed. Not marking them packed makes the code portable to non-gcc
> compilers.
>

Maybe __packed is used somewhere to hint that some members of a
structure maybe unaligned.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
