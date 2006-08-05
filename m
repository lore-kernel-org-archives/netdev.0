From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Sat, 05 Aug 2006 09:13:51 +0200
Message-ID: <44D4452F.5090406@trash.net>
References: <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801122916.GA6177@gondor.apana.org.au> <44D1C205.4010509@trash.net> <20060803093309.GB8808@gondor.apana.org.au> <44D1C471.2050503@trash.net> <20060803095703.GA9082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48787 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422676AbWHEHNv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:13:51 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060803095703.GA9082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 03, 2006 at 11:40:01AM +0200, Patrick McHardy wrote:
> 
>>Yes, the 32-bit thing is a bug, I meant it works fine without inverting
>>the checksum.
> 
> 
> Right, I forgot about the checksum invariance under negation.  In that
> case we can get rid of the tildes two lines down as well for consistency.

I've made the other changes you suggested, but removing the tildes here
didn't work, so I left them in. I'll send the new patches in a few
minutes.
