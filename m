From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Fri, 14 Aug 2009 23:36:43 +0200
Message-ID: <20090814213643.GA3179@ami.dom.local>
References: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:32909 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076AbZHNVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 17:37:04 -0400
Received: by bwz22 with SMTP id 22so1369772bwz.18
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 14:37:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2009 at 06:54:58PM +0530, Krishna Kumar wrote:
> =EF=BB=BFHi Jarek,
>=20
> Jarek Poplawski <jarkao2@gmail.com> wrote on 08/14/2009 04:31:27 PM:
>=20
> > Alas, private or public, these values are lower on average than
> > before, so I'm not sure the complexity (especially in reading) adde=
d
> > by this patch is worth it. So, I can only say it looks formally OK,
> > except the changelog and maybe 2 cosmetical suggestions below.
>=20
> Maybe the different test parameters result in smaller improvements.
> I agree with you - the first approach is very readable and probably
> preferable, while the second introduces a new structure and more
> complexity.

Actually, I meant the complexity added by any of these versions. If
you declare: "This helps in faster lookup for a skb when there are no
high priority skbs.", there is a question if less than 1% is enough.

> I am sending both these versions a last time, after fixing your
> comments in case someone can help decide if one or the other is
> better (sorry I forgot to run checkpatch couple of times, will try
> to remember next time).

I definitely can't see a reason to make this variable public, and
prefer the private (v2) version (which still lacks a changelog, btw).

Thanks,
Jarek P.
