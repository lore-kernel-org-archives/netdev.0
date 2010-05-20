From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Add classid to sk_buff.
Date: Wed, 19 May 2010 20:47:06 -0700 (PDT)
Message-ID: <20100519.204706.38048419.davem@davemloft.net>
References: <20100519.195538.139536660.davem@davemloft.net>
	<20100520033643.GA6630@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753595Ab0ETDq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:46:57 -0400
In-Reply-To: <20100520033643.GA6630@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 May 2010 13:36:43 +1000

> On Wed, May 19, 2010 at 07:55:38PM -0700, David Miller wrote:
>> 
>> We make this zero cost by moving queue_mapping into an existing
>> empty __u16 slot.  Thus making a __u32 available, which we use
>> for the 'classid'.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> You better hide this space before someone steals it :)

Indeed, I didn't even know we had it to begin with. :)
