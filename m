From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Mon, 31 Jul 2006 14:54:05 -0700 (PDT)
Message-ID: <20060731.145405.115929492.davem@davemloft.net>
References: <44CE4DCA.8000609@trash.net>
	<20060731.141559.95507027.davem@davemloft.net>
	<44CE77DD.9030902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20887
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751363AbWGaVyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 17:54:49 -0400
To: kaber@trash.net
In-Reply-To: <44CE77DD.9030902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Jul 2006 23:36:29 +0200

> David Miller wrote:
> > Does this matter?
> 
> I don't think it does. Its a huge corner case (unloading of the
> module which issued the QUEUE verdict while queueing the packet),
> and worst case is that we drop some segments or the entire packet.

Ok, that's what I thought.
