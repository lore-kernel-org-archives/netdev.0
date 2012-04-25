From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp repair: Fix unaligned access when repairing options
Date: Wed, 25 Apr 2012 14:09:46 -0400 (EDT)
Message-ID: <20120425.140946.205898008058818096.davem@davemloft.net>
References: <4F97EFA9.2080903@parallels.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6EF2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab2DYSJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 14:09:53 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EF2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Wed, 25 Apr 2012 15:11:30 +0100

>  
>> +struct tcp_repair_opt {
>> +	__u8	opt_code;
>> +	__u16	opt_val;
>> +};
> 
> That structure has an implied pad field, probably best to
> either make it explicit or change the types.

Agreed.
