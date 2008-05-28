From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 21:02:02 +0300
Message-ID: <200805282102.02805.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <200805282008.02136.opurdila@ixiacom.com> <20080528175110.GA6210@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4629 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753718AbYE1SDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 14:03:14 -0400
In-Reply-To: <20080528175110.GA6210@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 May 2008, Evgeniy Polyakov wrote:

> We queue data under the lock and clone appropriate skb (and then grab it
> multiple times), so even it will be dropped, its data will not freed, and
> thus we will be able to read it. Or you are talking about different
> skbs?

You are right, I forgot about the clone.

Thanks,
tavi
