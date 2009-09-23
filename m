From: Alexandre Cassen <acassen@freebox.fr>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Wed, 23 Sep 2009 13:07:27 +0200
Message-ID: <1253704047.17175.48.camel@lnxos-dev>
References: <20090922220251.GA22874@lnxos.staff.proxad.net>
	 <20090923184314.a2a2701d.yoshfuji@linux-ipv6.org>
Reply-To: acassen@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:39011 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbZIWLIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 07:08:13 -0400
In-Reply-To: <20090923184314.a2a2701d.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 18:43 +0900, YOSHIFUJI Hideaki wrote:
> Hello.
> 
> First of all, thank you for this work.
> 
> On Wed, 23 Sep 2009 00:02:51 +0200
> Alexandre Cassen <acassen@freebox.fr> wrote:
> 
> > This patch add support to 6rd tunnel mode as described into
> > draft-despres-6rd-03.
> > 
> > Patch history :
> > * http://patchwork.ozlabs.org/patch/26870/
> > * http://patchwork.ozlabs.org/patch/34026/
> > * http://patchwork.ozlabs.org/patch/34045/
> > 
> > IPv6 rapid deployment (draft-despres-6rd-03) builds upon mechanisms
> 
> Well, I was confused.  I think draft-softwire-ipv6-6rd
> is the latest one, no?

draft-despres-6rd-03    : targeting informational RFC
                          (=> currently pending)
draft-softwire-ipv6-6rd : targeting standard track

after last IETF meeting previous draft-townsley-ipv6-6rd as been pushed
to IETG softwires WG.

So you right, ref should be set to draft-softwire-ipv6-6rd.

> Another comment is that we should combine 6to4
> and 6rd.

Completly agree. 6to4 is a special case of 6rd.

Okay, so I stop producing (fixing according to last comments) and
resending new patch for 6rd.

regs,
Alexandre

