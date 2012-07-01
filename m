From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules with ethtool
Date: Sun, 01 Jul 2012 20:48:59 +0200
Message-ID: <m2ipe72u78.fsf@igel.home>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	<1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
	<1341160685.2032.15.camel@joe2Laptop>
	<1341163872.2032.29.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.co.il>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60141 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab2GAStF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 14:49:05 -0400
In-Reply-To: <1341163872.2032.29.camel@joe2Laptop> (Joe Perches's message of
	"Sun, 01 Jul 2012 10:31:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> On Sun, 2012-07-01 at 09:38 -0700, Joe Perches wrote:
>
>> I think this macro is suboptimal because
>> negated names are easy to misuse.
>> 
>> I think type is also unnecessary and too
>> easy to mismatch or keep up to date with
>> field type changes.
>> 
>> Perhaps it's better as:
>> 
>> #define all_zeros_or_all_ones(field)		\
>> ({						\
>> 	field && (typeof(field))~field;		\
>> })
>
> Umm, or not.
>
> It helps when I actually test the code not just type
> it into an email client.
>
> 	!(field && (typeof(field))~field)

Or write it as (!field || !(typeof(field))~field) which more closely
resembles what the macro name expresses.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
