From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 11:23:22 +0200
Message-ID: <1272014602.7895.7845.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1271970199.7895.6482.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
	 <alpine.LSU.2.01.1004230922120.24961@obet.zrqbmnf.qr>
	 <1272008780.7895.7746.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1004230955030.26168@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:65002 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445Ab0DWJXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 05:23:36 -0400
In-Reply-To: <alpine.LSU.2.01.1004230955030.26168@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 avril 2010 =C3=A0 09:55 +0200, Jan Engelhardt a =C3=A9cr=
it :
> On Friday 2010-04-23 09:46, Eric Dumazet wrote:
> >Years ago, we had to manually change PAGE_OFFSET, and I remember som=
e
> >machines with PAGE_OFFSET 0xA0000000  (1.5 GB LOWMEM),=20
> >or 0xB0000000 (1.25 GB), (PAE off)
>=20
> I notice that 0xB0000000, which is now known as LOWMEM_3G_OPT,
> is only available when PAE is off. Would you know the reason for
> that decision? Are some values unsuitable for PAE?
>=20

If PAE was on, PAGE_OFFSET must be a 1GB multiple.
This is because of hardware limitations.


