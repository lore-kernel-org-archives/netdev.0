From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Fri, 7 Jul 2006 13:57:11 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BD9C@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:33038 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751254AbWGGU5X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 16:57:23 -0400
Content-class: urn:content-classes:message
To: ravinandan.arakali@neterion.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ravinandan Arakali wrote:
> Michael,
> Are network cards expected to be aware-of and implement 
> RFC3540(ECN with
> nonces) ?
> 
Hi Ravi,

RFC3540 is still experimental I believe and it is not implemented
in the Linux stack.  Even if it is implemented and the NS bit is set,
I think the TSO logic can simply replicate the NS bit as each TSO
divided segment contains the same acknowledgement information from
the original super segment.

We should hear Herbert, David, or others' opinions on this.


