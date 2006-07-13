From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: jumbo frames and memory fragmentation
Date: Thu, 13 Jul 2006 22:13:42 +1000
Message-ID: <E1G104c-0007qF-00@gondolin.me.apana.org.au>
References: <44A56520.5010703@nortel.com>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54540 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751535AbWGMMOA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 08:14:00 -0400
To: cfriesen@nortel.com (Chris Friesen)
In-Reply-To: <44A56520.5010703@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortel.com> wrote:
> Herbert Xu wrote:
> 
>> Either upgrade your kernel or backport the page-splitting code in the
>> current tree.  That's really the only sane solution for jumbo packets.
> 
> Looking at the page-splitting code, it says "82571 and greater support 
> packet-split...".  We're running the 82546GB device.  Looks like it 
> won't help me.

Well, time to fork out for a new card then :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
