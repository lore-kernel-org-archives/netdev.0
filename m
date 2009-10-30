From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] gro: Change all receive functions to return GRO
 result codes
Date: Thu, 29 Oct 2009 21:29:39 -0700 (PDT)
Message-ID: <20091029.212939.05027354.davem@davemloft.net>
References: <1256836695.2827.71.camel@achroite>
	<20091029174823.GB30749@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753710AbZJ3E3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:29:15 -0400
In-Reply-To: <20091029174823.GB30749@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Oct 2009 13:48:23 -0400

> On Thu, Oct 29, 2009 at 05:18:15PM +0000, Ben Hutchings wrote:
>> This will allow drivers to adjust their receive path dynamically
>> based on whether GRO is being applied successfully.
>> 
>> Currently all in-tree callers ignore the return values of these
>> functions and do not need to be changed.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
