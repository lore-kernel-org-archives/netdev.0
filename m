From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCHv2 4/7] mISDN: Make layer1 timer 3 value configurable
Date: Fri, 04 May 2012 08:47:09 +0200
Message-ID: <4FA37B6D.3070001@linux-pingi.de>
References: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de> <1336060052-27119-5-git-send-email-kkeil@linux-pingi.de> <20120503.170830.1574473660496726919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:59521 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177Ab2EDGwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 02:52:53 -0400
In-Reply-To: <20120503.170830.1574473660496726919.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 03.05.2012 23:08, schrieb David Miller:
> From: Karsten Keil <kkeil@linux-pingi.de>
> Date: Thu,  3 May 2012 17:47:29 +0200
> 
>> @@ -372,6 +372,7 @@ clear_channelmap(u_int nr, u_char *map)
>>  #define MISDN_CTRL_RX_OFF		0x0100
>>  #define MISDN_CTRL_FILL_EMPTY		0x0200
>>  #define MISDN_CTRL_GETPEER		0x0400
>> +#define MISDN_CTRL_L1_TIMER3		0x0800
>>  #define MISDN_CTRL_HW_FEATURES_OP	0x2000
>>  #define MISDN_CTRL_HW_FEATURES		0x2001
>>  #define MISDN_CTRL_HFC_OP		0x4000
> 
> This define is completely unused by this patch.
> 
> To say that I'm frustrated by this process would be an understatement.
> 
> 

It is used in the next patch of the series. I usually make different
patches for core infrastructure  changes and the low level driver changes.
If you think it would be better to do this in one patch - I can provide
a new series.

Karsten
