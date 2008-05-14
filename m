From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Wed, 14 May 2008 10:19:57 +0200
Message-ID: <BAY103-DAV88950FC99CDE9EAAE27B2B2CE0@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl> <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl> <20080509102509.GA11710@gondor.apana.org.au> <BAY103-DAV5B5CD83FC6A95A5DD48C9B2CC0@phx.gbl> <20080512074642.GA1416@gondor.apana.org.au> <BAY103-DAV521435E26209347B7646FB2CC0@phx.gbl> <BAY103-DAV2A04E519F35401C98403FB2CC0@phx.gbl> <BAY103-DAV20B0EEFFB30A41A8020C8B2CC0@phx.gbl>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s2.bay0.hotmail.com ([65.54.246.74]:37086 "EHLO
	bay0-omc1-s2.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbYENIWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 04:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:

> Marco Berizzi wrote:
>
> > Marco Berizzi wrote:
> >
> > > Herbert Xu wrote:
> > >
> > > > On Mon, May 12, 2008 at 09:14:54AM +0200, Marco Berizzi wrote:
> > > > >
> > > > > PS: linux version shown by dmesg is 2.6.24 but it
> > > > > is the results of 'git bisect good v2.6.24' and
> > > > > 'git bisect bad v2.6.25'
> > > >
> > > > So what's the changeset hash for the source that produced this
> > > > kernel?

This kernel (see below git bisect log) has not
been crashed after more than 17 hours. I want
to test it till this evening.
This is the git bisect log:

root@Calimero:/tmp/GIT/herbert# git bisect log
git-bisect start
# good: [49914084e797530d9baaf51df9eda77babc98fa8] Linux 2.6.24
git-bisect good 49914084e797530d9baaf51df9eda77babc98fa8
# bad: [4b119e21d0c66c22e8ca03df05d9de623d0eb50f] Linux 2.6.25
git-bisect bad 4b119e21d0c66c22e8ca03df05d9de623d0eb50f
# bad: [dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf] Merge branch
'audit.b46' of
git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
git-bisect bad dd5f5fed6c9458a7aa81eeef3732cc3a9891cfdf
# bad: [fde3571fd8613483f1203d11394ae316c6b79a03] iwlwifi: avoid
firmware command sending if rfkill is enabled
git-bisect bad fde3571fd8613483f1203d11394ae316c6b79a03
# good: [1c7c2cdec3a6b2873439096983794a550d7ff65b] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
git-bisect good 1c7c2cdec3a6b2873439096983794a550d7ff65b
# bad: [4c37799ccf6c722e0dad6a0677af22d1c23fb897] [NETFILTER]: Use
lowercase names for matches in Kconfig
git-bisect bad 4c37799ccf6c722e0dad6a0677af22d1c23fb897

I hope this helps.

PS: I always replace from 2.6.25 ipcomp.c and
xfrm4_tunnel.c


