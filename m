From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/3] net: tcp: make hybla selectable as default congestion
 module
Date: Thu, 11 Mar 2010 21:19:24 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003112115320.9240@obet.zrqbmnf.qr>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de> <1268337450-6749-2-git-send-email-jengelh@medozas.de> <20100311121032.3b9213e1@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45911 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404Ab0CKUTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:19:25 -0500
In-Reply-To: <20100311121032.3b9213e1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-03-11 21:10, Stephen Hemminger wrote:
>> 
>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index 0c94a1a..731c47b 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -587,6 +587,9 @@ choice
>>  	config DEFAULT_HTCP
>>  		bool "Htcp" if TCP_CONG_HTCP=y
>>  
>> +	config DEFAULT_HYBLA
>> +		bool "Hybla" if TCP_CONG_HYBLA=y
>> +
>>  	config DEFAULT_VEGAS
>>  		bool "Vegas" if TCP_CONG_VEGAS=y
>>  
>> @@ -610,6 +613,7 @@ config DEFAULT_TCP_CONG
>>  	default "bic" if DEFAULT_BIC
>>  	default "cubic" if DEFAULT_CUBIC
>>  	default "htcp" if DEFAULT_HTCP
>> +	default "hybla" if DEFAULT_HYBLA
>>  	default "vegas" if DEFAULT_VEGAS
>>  	default "westwood" if DEFAULT_WESTWOOD
>>  	default "reno" if DEFAULT_RENO
>
>Hybla seems too experimental to be made default.

I run Hybla since 2006 on anything that is not connected via
wireless and I did not notice any pressing issues.

Also, the patch does not make hybla the default default (reno remains),
just the default once explicitly selected in a two-step process:

1. CONFIG_TCP_CONG_HYBLA=y
*and*
2. choosing Hybla in CONFIG_DEFAULT_TCP_CONG

I think that is enough of a "safety measure" against any potential
unsuspecting users.
