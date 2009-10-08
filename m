From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Thu, 08 Oct 2009 15:08:33 -0700 (PDT)
Message-ID: <20091008.150833.03012683.davem@davemloft.net>
References: <4ACE023D.9030208@gmail.com>
	<19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mingo@elte.hu
To: vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932125AbZJHWIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 18:08:39 -0400
In-Reply-To: <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Thu, 8 Oct 2009 23:54:02 +0200

> Hm, no, this looks wrong to me, because sk_protocol and sk_type
> _aren't_ in fact part of the bitfield.
> 
> We don't want to affect the kernel _at all_ when CONFIG_KMEMCHECK=n,
> so I guess we should make the kmemcheck_bitfield_{begin|end}() macros
> empty instead for that case? (And for kmemcheck kernels, we don't
> really care about the lost 8 bytes anyway.)

Hmmm, indeed.

Eric I'm holding this patch off for now.
