From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCHes] pull request: WAN
Date: Wed, 23 Jul 2008 23:31:13 +0200
Message-ID: <m3hcags2xq.fsf@maximus.localdomain>
References: <m3ljzyc9e7.fsf@maximus.localdomain> <488653A9.50001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57024 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbYGWVbQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:31:16 -0400
In-Reply-To: <488653A9.50001@garzik.org> (Jeff Garzik's message of "Tue\, 22 Jul 2008 17\:39\:53 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

> Anything in upstream-next went upstream, and so we need to apply this
> on top of the current Linus upstream (torvalds/linux-2.6.git) at the
> very least.
>
> Would you mind doing that, please?

No problem, though I guess David would hate us both if I do that,
so I actually rebased on top of your "upstream" instead, is it ok?

It's now at:

git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-j=
eff

> Also, git pulls are great, but it would be helpful if you supply a
> git-shortlog summary of the changes, and the patch (>400k will only g=
o
> to me, list will ignore).

Sure,

Krzysztof Ha=B3asa (15):
      WAN: cosmetic changes to generic HDLC
      Remove bogus dosyncppp variable from synclink drivers.
      Remove bogus variables from syncppp.[ch]
      Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't e=
xist
      wanmain.c doesn't need syncppp.h
      WAN: Remove unneeded "#include <net/syncppp.h>"
      WAN: Remove dead code from PC300 driver, part #1
      WAN: Remove dead code from PC300 driver, part #2
      WAN: Convert PC300 driver to use normal u8/u16/u32 types
      WAN: farsync driver no longer uses syncppp.c directly
      WAN: Port COSA driver to generic HDLC.
      WAN: Convert Zilog-based drivers to generic HDLC
      WAN: Port LMC driver to generic HDLC
      WAN: don't mention syncppp in z8530 DocBook.
      WAN: Use u32 type instead of u_int32_t in LMC driver.

The combined patch follows.
--=20
Krzysztof Halasa
