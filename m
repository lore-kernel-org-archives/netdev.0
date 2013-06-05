From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v3] include/linux/skbuff.h: using '(__u16) ~0U' instead
 of '~0U'
Date: Wed, 05 Jun 2013 19:15:57 +0800
Message-ID: <51AF1DED.6050305@asianux.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7263@saturn3.aculab.com> <51AE89DE.60106@asianux.com> <51AE8C3E.8060605@asianux.com> <20130605.013601.2203042571724866964.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, andy.shevchenko@gmail.com,
	edumazet@google.com, pshelar@nicira.com, mgorman@suse.de,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:48791 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465Ab3FELQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 07:16:52 -0400
In-Reply-To: <20130605.013601.2203042571724866964.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2013 04:36 PM, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Wed, 05 Jun 2013 08:54:22 +0800
> 
>> > 
>> > Both 'transport_header' and 'mac_header' are __u16, which are
>> > never equal to '~0U'.
>> > 
>> > So need use '(__u16) ~0U' instead of '~0U'.
>> > 
>> > The related warning (with EXTRA_CFLAGS=-W ARCH=m68k for allmodconfig)
>> >   include/linux/skbuff.h:1587:2: warning: comparison is always true due to limited range of data type [-Wtype-limits]
>> >   ...
>> > 
>> > Use meaningful macro instead of hard code number, and better to
>> > initialize 'skb->transport_header' in __alloc_skb_head(), too.
>> > 
>> > 
>> > 
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Your patch doesn't apply to the tree because this has been fixed already
> for several days by using "typeof(x) ~0U"
> 
> 

OK, thanks.

-- 
Chen Gang

Asianux Corporation
