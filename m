From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Sat, 21 Aug 2010 10:07:35 +0200
Message-ID: <20100821080735.GA2409@del.dom.local>
References: <4C6E5EA7.3040609@fs.uni-ruse.bg>
 <20100820193835.GA6025@del.dom.local>
 <20100821074742.GA2367@del.dom.local>
 <1282377058.2636.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60109 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab0HUIHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 04:07:43 -0400
Received: by bwz11 with SMTP id 11so2683865bwz.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 01:07:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1282377058.2636.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 21, 2010 at 09:50:58AM +0200, Eric Dumazet wrote:
> Le samedi 21 ao=C3=BBt 2010 =C3=A0 09:47 +0200, Jarek Poplawski a =C3=
=A9crit :
> > On Fri, Aug 20, 2010 at 09:38:35PM +0200, Jarek Poplawski wrote:
> > > Plamen Petrov wrote, On 20.08.2010 12:53:
> > > > So, I guess its David and Herbert's turn?...
> > >=20
> > > If you're bored in the meantime I'd suggest to do check the realt=
ek
> > > driver eg:
> > > - for locking with the patch below,
> > > - to turn off with ethtool its tx-checksumming and/or scatter-gat=
her,
> >=20
> > After rethinking, it's almost impossible this patch could change
> > anything here, so don't bother, but consider mainly the second
> > proposal.
> >=20
> > Jarek P.
>=20
> Indeed ;)
>=20
> Its true that not many nics use the skb_copy_and_csum_dev() helper,
> maybe this one must be updated somehow ?
>=20
Yes, it seems it should be possible at least to handle the bug with
a warning and error return, considering Plamen's problems with getting
the trace.

Jarek P.
