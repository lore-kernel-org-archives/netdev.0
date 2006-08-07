From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Sun, 06 Aug 2006 19:44:47 -0700 (PDT)
Message-ID: <20060806.194447.109339874.davem@davemloft.net>
References: <1154920659.3388.4.camel@LINE>
	<E1G9v2g-0000rZ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@nanjing-fnst.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35537
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750921AbWHGCoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 22:44:32 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1G9v2g-0000rZ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 07 Aug 2006 12:40:34 +1000

> The general approach looks sound.  I have one esoteric question
> though.  If a retransmitted packet is coalesced with one that is
> yet to be transmitted (a fairly unlikely scenario, but possible I
> think), should it count towards OUTSEGS?

Probably the packet should be counted to OUTSEGS if any of it contains
new data.
