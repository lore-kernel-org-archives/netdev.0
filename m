From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Mon, 24 Jul 2006 23:36:53 -0700 (PDT)
Message-ID: <20060724.233653.71166298.davem@davemloft.net>
References: <20060718113245.GA12040@gondor.apana.org.au>
	<20060718125439.GA19770@ms2.inr.ac.ru>
	<20060718130404.GA12785@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yjwei@nanjing-fnst.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33213
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751459AbWGYGhE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 02:37:04 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060718130404.GA12785@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 18 Jul 2006 23:04:04 +1000

> Actually, I plan to differentiate between RX CHECKSUM_HW and TX
> CHECKSUM_HW.  Now that we have things like Xen it is possible for
> RX packets to have patial checksums too.
> 
> When this is done loopback can send TX CHECKSUM_HW packets instead
> of CHECKSUM_UNNECESSARY (I'm currently calling this CHECKSUM_PARTIAL).

This sounds like a good idea.

Undoing CHECKSUM_UNNECESSARY when trimming is definitely going to
break loopback the way things are done currently.
