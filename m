From: David Miller <davem@davemloft.net>
Subject: Re: skb_shared_info()
Date: Tue, 08 Aug 2006 22:50:28 -0700 (PDT)
Message-ID: <20060808.225028.71086869.davem@davemloft.net>
References: <20060809003616.GC19881@gondor.apana.org.au>
	<20060808.175839.85396148.davem@davemloft.net>
	<20060809053524.GC17446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59270
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965080AbWHIFu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:50:27 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060809053524.GC17446@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 09:35:24 +0400

> We can separate kmalloced data from page by using internal page structures
> (lru pointers and PG_slab bit).

Yes, it is one idea.
