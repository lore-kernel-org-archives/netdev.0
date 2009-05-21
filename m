From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix length computation in rt_check_expire()
Date: Wed, 20 May 2009 17:19:26 -0700 (PDT)
Message-ID: <20090520.171926.153405845.davem@davemloft.net>
References: <20090519.150517.62361946.davem@davemloft.net>
	<4A138CFE.5070901@cosmosbay.com>
	<20090520102754.GA25492@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751996AbZEUAT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:19:29 -0400
In-Reply-To: <20090520102754.GA25492@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 20 May 2009 06:27:54 -0400

> On Wed, May 20, 2009 at 06:54:22AM +0200, Eric Dumazet wrote:
>> [PATCH] net: fix length computation in rt_check_expire()
>> 
>> rt_check_expire() computes average and standard deviation of chain lengths,
>> but not correclty reset length to 0 at beginning of each chain.
>> This probably gives overflows for sum2 (and sum) on loaded machines instead 
>> of meaningful results.
>> 
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

Applied and queued up for -stable.
