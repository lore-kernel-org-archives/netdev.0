From: David Miller <davem@davemloft.net>
Subject: Re: cxgb4: Use ntohs() on __be16 value instead of htons()
Date: Wed, 21 Apr 2010 23:00:59 -0700 (PDT)
Message-ID: <20100421.230059.41959097.davem@davemloft.net>
References: <ada1ve8r832.fsf@roland-alpha.cisco.com>
	<4BCF4F57.4050802@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034Ab0DVGAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:00:55 -0400
In-Reply-To: <4BCF4F57.4050802@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Wed, 21 Apr 2010 12:17:43 -0700

> On 04/21/2010 11:09 AM, Roland Dreier wrote:
>> Use the correct direction of byte-swapping function to fix a mistake
>> shown by sparse endianness checking -- c.fl0id is __be16.
>>
>> Signed-off-by: Roland Dreier<rolandd@cisco.com>
> 
> Yes, thanks.
> 
> Acked-by: Dimitris Michailidis <dm@chelsio.com>

Applied to net-next-2.6
