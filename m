From: "Arce, Abraham" <x0066660@ti.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Wed, 8 Sep 2010 18:27:16 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A530450AB386F@dlee03.ent.ti.com>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
	 <1274851741.25136.16.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
	 <1274906933.2542.17.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A5304509AF8DA@dlee03.ent.ti.com>
 <1283962550.2748.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:49697 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655Ab0IHX1U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:27:20 -0400
In-Reply-To: <1283962550.2748.92.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric,

> Le mardi 07 septembre 2010 =E0 16:43 -0500, Arce, Abraham a =E9crit :
> > > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]

[..]

> > How about the following patch? I am using added helper function:
> > netdev_alloc_skb_ip_align()
>=20
> Hmm, I prefer following patch (not tested), to really cope with
> allocation errors (instead of crashing because of NULL dereference), =
and
> allocate and skb of exactly the needed size.

Patch tested, 2 minor modifications:

 - Added an ending brace
 - Line size correction

It has been tested in a SDP OMAP4 ES1.0

- Filesystem over nfs
- Multiple file creation
- Throughput measurement

I'll send it as a new patch

 [PATCH] KS8851: Correct RX packet allocation

Best Regards
Abraham

