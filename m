From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 01 Aug 2006 09:38:06 +0200
Message-ID: <44CF04DE.20408@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801072358.GB3802@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:13034 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1161015AbWHAHiI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:38:08 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801072358.GB3802@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
>>- tc_verd/tc_index/input_dev: when directing a packet from a device
>>  supporting GSO to a device not supporting GSO using tc actions,
>>  these fields may be set.
> 
> 
> This doesn't look right though.  GSO should occur just before
> hard_start_xmit (after all tc actions have taken place) so we
> shouldn't have any more tc actions to perform.

You're right, this part shouldn't be necessary. It might be possible
to construct some case with loopback, but I doubt it would be very
realistic.

