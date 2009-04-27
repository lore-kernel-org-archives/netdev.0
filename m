From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 02:32:41 -0700 (PDT)
Message-ID: <20090427.023241.171629284.davem@davemloft.net>
References: <49F1E5C8.7010303@myri.com>
	<20090427080501.GA21433@gondor.apana.org.au>
	<20090427080735.GA21493@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753147AbZD0Jcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:32:48 -0400
In-Reply-To: <20090427080735.GA21493@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 27 Apr 2009 16:07:35 +0800

> On Mon, Apr 27, 2009 at 04:05:01PM +0800, Herbert Xu wrote:
>> 
>> OK, I'd created a silly bug with the skb_gro_* optimisation.
>> Here are two patches to fix them.
>> 
>> gro: Fix handling of headers that extend over the tail
> 
> gro: Fix COMPLETE checksum handling

These look good, want me to toss them into net-next-2.6?
