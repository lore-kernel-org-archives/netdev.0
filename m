From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 03/16] ixgbe: cleanup sparse errors in new
 ixgbe_x550.c file
Date: Thu, 05 Feb 2015 14:40:07 -0800 (PST)
Message-ID: <20150205.144007.1425782923410995381.davem@davemloft.net>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1423128950-12388-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CADC3FA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbbBEWkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 17:40:08 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CADC3FA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 5 Feb 2015 09:48:24 +0000

> From: Jeff Kirsher
>> This patch cleans up prototypes that should have been defined
>> as static.
>> 
>> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  4 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 65 ++++++++++++++-------------
>>  2 files changed, 37 insertions(+), 32 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> index d101b25..1f301ec 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> @@ -2451,8 +2451,8 @@ struct ixgbe_hic_read_shadow_ram {
>> 
>>  struct ixgbe_hic_write_shadow_ram {
>>  	union ixgbe_hic_hdr2 hdr;
>> -	u32 address;
>> -	u16 length;
>> +	__be32 address;
>> +	__be16 length;
>>  	u16 pad2;
>>  	u16 data;
>>  	u16 pad3;
> 
> Not related to commit message

Agreed, fix this up.
