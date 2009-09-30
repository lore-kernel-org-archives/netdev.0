From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] bonding: send ARP requests on interfaces other
	than the primary for tlb/alb
Date: Wed, 30 Sep 2009 05:40:15 +0000
Message-ID: <20090930054015.GA5231@ff.dom.local>
References: <4AC2EA97.5010809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:3153 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbZI3FkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 01:40:18 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1999829fge.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 22:40:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AC2EA97.5010809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-09-2009 07:20, Eric Dumazet wrote:
...
>> +	/* Choose an output channel for the ARP frame */
>> +	tx_slave = rlb_choose_channel(skb, bond);
>>  
>> -		/* The ARP relpy packets must be delayed so that
>> -		 * they can cancel out the influence of the ARP request.
>> -		 */
> 
> COmments should have the following form :
> /*
>  * This is a fine comment
>  */

It's "The preferred style for long (multi-line) comments [...]".

Jarek P.
