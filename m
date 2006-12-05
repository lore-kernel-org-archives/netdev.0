From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 1/7] Sync with 2.6.19 kernel header about include/linux.
Date: Tue, 05 Dec 2006 20:44:53 +0900
Message-ID: <45755BB5.2060707@linux-ipv6.org>
References: <11653137213434-git-send-email-nakam@linux-ipv6.org> <20061205104211.GW8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:43575 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S937517AbWLELo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 06:44:57 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061205104211.GW8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Masahide NAKAMURA <nakam@linux-ipv6.org> 2006-12-05 19:15
>> diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
>> index 8270aac..4418c8d 100644
>> --- a/include/linux/fib_rules.h
>> +++ b/include/linux/fib_rules.h
>> @@ -6,7 +6,6 @@ #include <linux/rtnetlink.h>
>>  
>>  /* rule is permanent, and cannot be deleted */
>>  #define FIB_RULE_PERMANENT	1
>> -#define FIB_RULE_INVERT		2
>>
>>  struct fib_rule_hdr
>>  {
>> @@ -35,7 +34,7 @@ enum
>>  	FRA_UNUSED3,
>>  	FRA_UNUSED4,
>>  	FRA_UNUSED5,
>> -	FRA_FWMARK,	/* mark */
>> +	FRA_FWMARK,	/* netfilter mark */
>>  	FRA_FLOW,	/* flow/class id */
>>  	FRA_UNUSED6,
>>  	FRA_UNUSED7,
> 
> Why are you reverting this?

I just update the header about include/linux without thinking.
Should I have to update them except fib_rules.h?

Anyway, I'll fix "[PATCH 1/7]" and send it again.

Thanks,


-- 
Masahide NAKAMURA
