From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 10/11] e1000e: fix sparse warnings with
 -D__CHECK_ENDIAN__
Date: Tue, 07 Feb 2012 12:16:33 -0500 (EST)
Message-ID: <20120207.121633.43514871391885371.davem@davemloft.net>
References: <1328618038-5008-11-git-send-email-jeffrey.t.kirsher@intel.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6E5C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab2BGRQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:16:42 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E5C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 7 Feb 2012 12:58:35 -0000

>  
>>  	for (i = 0; i < last_word - first_word + 1; i++)
>> -		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
>> +		cpu_to_le16s(&eeprom_buff[i]);
> 
> The old version is likely to generate much better code.

Not on cpus that have swap-endian loads and stores.
