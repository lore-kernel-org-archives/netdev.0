From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Thu, 19 Jun 2008 22:43:12 +0200
Message-ID: <20080619204312.GA2160@electric-eye.fr.zoreil.com>
References: <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net> <48593E35.1010409@e-teleport.net> <20080618201012.GA4019@electric-eye.fr.zoreil.com> <48598784.40306@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39585 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbYFSUnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 16:43:41 -0400
Content-Disposition: inline
In-Reply-To: <48598784.40306@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S=C3=A9guier R=C3=A9gis <rseguier@e-teleport.net> :
>> I have updated http://userweb.kernel.org/~romieu/via-velocity/2.6.26=
-rc6/
[...]
> Patch 0001 doesn't work,
>
> if I don't make a mistake skb->len is not modified in skb_pad{,to}whe=
n the=20
> padding is applied. In this case, we need to attribute ETH_ZLEN to le=
n.

Yes, that's what the driver did beforehand.

The updated serie is at the usual place. Does it perform better ?

--=20
Ueimor
