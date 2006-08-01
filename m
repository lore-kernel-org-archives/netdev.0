From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Tue, 01 Aug 2006 00:36:14 -0700 (PDT)
Message-ID: <20060801.003614.54188740.davem@davemloft.net>
References: <44CE4DCA.8000609@trash.net>
	<44CF0086.1030404@trash.net>
	<20060801072358.GB3802@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29917
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161345AbWHAHg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:36:56 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060801072358.GB3802@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 1 Aug 2006 17:23:58 +1000

> > - tc_verd/tc_index/input_dev: when directing a packet from a device
> >   supporting GSO to a device not supporting GSO using tc actions,
> >   these fields may be set.
> 
> This doesn't look right though.  GSO should occur just before
> hard_start_xmit (after all tc actions have taken place) so we
> shouldn't have any more tc actions to perform.

Hmmm, what about loopback?  Yeah yeah, LOOPBACK_TSO is not defined :)
but what I'm really referring to is that loopback preserves the
traffic classifier bits of the skb.
