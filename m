From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] fragment locally generated tunnel-mode IPSec6
 packets as needed
Date: Sat, 18 Dec 2010 14:34:23 -0800 (PST)
Message-ID: <20101218.143423.189688024.davem@davemloft.net>
References: <1292622162.1700.3.camel@IBM-1B506CFC885>
	<20101218021606.GA26888@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751406Ab0LRWdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 17:33:54 -0500
In-Reply-To: <20101218021606.GA26888@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 18 Dec 2010 10:16:06 +0800

> On Fri, Dec 17, 2010 at 01:42:42PM -0800, David L Stevens wrote:
>> This patch modifies IPsec6 to fragment IPv6 packets that are
>> locally generated as needed.
>> 
>> This version of the patch only fragments in tunnel mode, so that fragment
>> headers will not be obscured by ESP in transport mode.
>> 
>> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

So is the TAHI test regression caused by v3 fixed here in v4?
