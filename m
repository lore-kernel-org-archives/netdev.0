From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules with ethtool
Date: Mon, 02 Jul 2012 13:35:49 +0200
Message-ID: <m28vf2o0oa.fsf@igel.home>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F70@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Joe Perches" <joe@perches.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, "Hadar Hen Zion" <hadarh@mellanox.co.il>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:58825 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab2GBLf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 07:35:58 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F70@saturn3.aculab.com>
	(David Laight's message of "Mon, 2 Jul 2012 11:19:50 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"David Laight" <David.Laight@ACULAB.COM> writes:

>  
>> > Or write it as (!field || !(typeof(field))~field) which more closely
>> > resembles what the macro name expresses.
>> 
>> Better still, or maybe:
>> 
>> 	field == 0 || field == (typeof field)~0
>
> Which doesn't work when sizeof(field) > sizeof(int).
> Needs another cast.
>
> 	field == 0 || field == (typeof field)~(typeof field)0

You can avoid that by using (typeof field)-1.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
