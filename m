From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 02/05: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
Date: Mon, 30 Nov 2009 21:23:14 +0100
Message-ID: <4B1429B2.8070308@trash.net>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175532.7555.11857.sendpatchset@x2.localnet> <4B142941.2020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58987 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbZK3UXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:23:11 -0500
In-Reply-To: <4B142941.2020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 11/30/2009 06:55 PM:
> 
>> commit dc4427ae3647195508b4df883050a9f0ef111165
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Mon Nov 30 15:54:05 2009 +0100
>>
>>     net: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
>>     
>>     The next patch will add oif classification, rename interface related members
>>     and attributes to reflect that they're used for iif classification.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>> diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
>> index c7e5b70..e3c91af 100644
>> --- a/include/linux/fib_rules.h
>> +++ b/include/linux/fib_rules.h
>> @@ -8,7 +8,8 @@
>>  #define FIB_RULE_PERMANENT	0x00000001
>>  #define FIB_RULE_INVERT		0x00000002
>>  #define FIB_RULE_UNRESOLVED	0x00000004
>> -#define FIB_RULE_DEV_DETACHED	0x00000008
>> +#define FIB_RULE_IIF_DETACHED	0x00000008
>> +#define FIB_RULE_DEV_DETACHED	FIB_RULE_DEV_DETACHED
> 
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Is it some trick?

D'oh, thanks for catching this :) I'll fix that up for the next
submission.
