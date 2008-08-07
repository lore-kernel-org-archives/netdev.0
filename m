From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCHes] pull request: WAN
Date: Thu, 07 Aug 2008 04:06:51 -0400
Message-ID: <489AAD1B.10901@garzik.org>
References: <m3ljzyc9e7.fsf@maximus.localdomain> <488653A9.50001@garzik.org> <m3hcags2xq.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41137 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815AbYHGIG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 04:06:56 -0400
In-Reply-To: <m3hcags2xq.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> Jeff Garzik <jeff@garzik.org> writes:
>=20
>> Anything in upstream-next went upstream, and so we need to apply thi=
s
>> on top of the current Linus upstream (torvalds/linux-2.6.git) at the
>> very least.
>>
>> Would you mind doing that, please?
>=20
> No problem, though I guess David would hate us both if I do that,
> so I actually rebased on top of your "upstream" instead, is it ok?
>=20
> It's now at:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for=
-jeff
>=20
>> Also, git pulls are great, but it would be helpful if you supply a
>> git-shortlog summary of the changes, and the patch (>400k will only =
go
>> to me, list will ignore).
>=20
> Sure,
>=20
> Krzysztof Ha=B3asa (15):
>       WAN: cosmetic changes to generic HDLC
>       Remove bogus dosyncppp variable from synclink drivers.
>       Remove bogus variables from syncppp.[ch]
>       Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't=
 exist
>       wanmain.c doesn't need syncppp.h
>       WAN: Remove unneeded "#include <net/syncppp.h>"
>       WAN: Remove dead code from PC300 driver, part #1
>       WAN: Remove dead code from PC300 driver, part #2
>       WAN: Convert PC300 driver to use normal u8/u16/u32 types
>       WAN: farsync driver no longer uses syncppp.c directly
>       WAN: Port COSA driver to generic HDLC.
>       WAN: Convert Zilog-based drivers to generic HDLC
>       WAN: Port LMC driver to generic HDLC
>       WAN: don't mention syncppp in z8530 DocBook.
>       WAN: Use u32 type instead of u_int32_t in LMC driver.

pulled


