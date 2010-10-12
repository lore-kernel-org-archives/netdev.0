From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
 enablement
Date: Tue, 12 Oct 2010 12:31:42 -0700 (PDT)
Message-ID: <20101012.123142.59664847.davem@davemloft.net>
References: <1286910141.16797.23.camel@lb-tlvb-dmitry>
	<1286911579.1117.76.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, vladz@broadcom.com, eilong@broadcom.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757373Ab0JLTbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 15:31:20 -0400
In-Reply-To: <1286911579.1117.76.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 12 Oct 2010 12:26:19 -0700

> On Tue, 2010-10-12 at 21:02 +0200, Dmitry Kravkov wrote:
>> @@ -2486,6 +2486,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
>>  	 * if (is_eth_multi(bp))
>>  	 *	flags |= FUNC_FLG_RSS;
>>  	 */
>> +	flags |= FUNC_FLG_RSS;
>>  
>>  	/* function setup */
>>  	if (flags & FUNC_FLG_RSS) {
> 
> Then the "if (flags & FUNC_FLG_RSS)" test should be removed.

Yeah it probably should.  If necessary it could be added back
later.
