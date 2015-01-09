From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/11] r8169:update rtl8168f pcie ephy
 parameter
Date: Thu, 08 Jan 2015 20:08:58 -0800 (PST)
Message-ID: <20150108.200858.548066819871890131.davem@davemloft.net>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
	<1420648826-12972-8-git-send-email-hau@realtek.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC2C99@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hau@realtek.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbbAIEDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 23:03:14 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC2C99@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 7 Jan 2015 16:45:58 +0000

> From: Chunhao Lin
>> @@ -5852,7 +5852,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
>>  		{ 0x06, 0x00c0,	0x0020 },
>>  		{ 0x08, 0x0001,	0x0002 },
>>  		{ 0x09, 0x0000,	0x0080 },
>> -		{ 0x19, 0x0000,	0x0224 }
>> +		{ 0x19, 0x0000,	0x0224 },
>> +		{ 0x00, 0x0000,	0x0008 },
>> +		{ 0x0c, 0x3df0,	0x0200 }
> 
> I can't help feeling these lines all require short comments.

Agreed.

And this goes for some of the other patches that look like this too.
