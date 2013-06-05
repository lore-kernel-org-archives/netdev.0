From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] include/linux/skbuff.h: using '(u16) ~0U' instead
 of '~0U'
Date: Wed, 05 Jun 2013 08:44:14 +0800
Message-ID: <51AE89DE.60106@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com> <51AC60AA.8010107@asianux.com> <CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com> <51AC7546.4010002@asianux.com> <51AC7CD4.2060801@asianux.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7262@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7263@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, edumazet@google.com,
	Pravin Shelar <pshelar@nicira.com>, mgorman@suse.de,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:49086 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3FED2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 23:28:32 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7263@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 08:47 PM, David Laight wrote:
>>> +#define SKB_HEADER_UNSET_16	((unsigned short) ~0U)
>>> > > +
>> > 
>> > The _16 part isn't really correct, the type could be changed
>> > and then it would be wrong.
>> > 
>> > I think I might have used SKB_HEADER_OFFSET.
> I meant SKB_HEADER_UNSET_OFFSET or SKB_HEADER_OFFSET_UNSET
> 

It sound good, I choose the 2nd: 'SKB_HEADER_OFFSET_UNSET', for it may
be a 'noun', not a 'sentence'.

I will send patch v3 (also use '__u16' instead of 'unsigned short')


Thanks.
-- 
Chen Gang

Asianux Corporation
