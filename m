From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Sat, 21 Aug 2010 09:50:58 +0200
Message-ID: <1282377058.2636.12.camel@edumazet-laptop>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg>
	 <20100820193835.GA6025@del.dom.local> <20100821074742.GA2367@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab0HUHvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 03:51:03 -0400
Received: by wyb32 with SMTP id 32so4585609wyb.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 00:51:02 -0700 (PDT)
In-Reply-To: <20100821074742.GA2367@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 21 ao=C3=BBt 2010 =C3=A0 09:47 +0200, Jarek Poplawski a =C3=A9=
crit :
> On Fri, Aug 20, 2010 at 09:38:35PM +0200, Jarek Poplawski wrote:
> > Plamen Petrov wrote, On 20.08.2010 12:53:
> > > So, I guess its David and Herbert's turn?...
> >=20
> > If you're bored in the meantime I'd suggest to do check the realtek
> > driver eg:
> > - for locking with the patch below,
> > - to turn off with ethtool its tx-checksumming and/or scatter-gathe=
r,
>=20
> After rethinking, it's almost impossible this patch could change
> anything here, so don't bother, but consider mainly the second
> proposal.
>=20
> Jarek P.

Indeed ;)

Its true that not many nics use the skb_copy_and_csum_dev() helper,
maybe this one must be updated somehow ?



