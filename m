From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/7] e1000e: use true/false for bool autoneg_false
Date: Thu, 09 Feb 2012 13:34:13 -0500 (EST)
Message-ID: <20120209.133413.349832435589531136.davem@davemloft.net>
References: <1328783282-17760-5-git-send-email-jeffrey.t.kirsher@intel.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab2BISeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:34:21 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E62@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 9 Feb 2012 13:15:37 -0000

>  
>> -		if (mac->autoneg_failed == 0) {
>> -			mac->autoneg_failed = 1;
>> +		if (mac->autoneg_failed == false) {
>> +			mac->autoneg_failed = true;
> 
> Don't check for equality with true/false.
> Booleans also work better if you avoid double-negatives.

Agreed.
