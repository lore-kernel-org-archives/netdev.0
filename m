From: David Miller <davem@davemloft.net>
Subject: Re: Crash in CIPSO_V4_TAG_LOCAL handling
Date: Tue, 17 Jul 2012 10:28:34 -0700 (PDT)
Message-ID: <20120717.102834.1867582159031908463.davem@davemloft.net>
References: <1342286550.23395.12.camel@monkey32>
	<20120714.130817.394766887121758073.davem@davemloft.net>
	<CAHC9VhQKhoRt8yD4WAgD5tyqjY4bbp4Z4hr5cWfs-d6GJt0pjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlin@ss.pku.edu.cn, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab2GQR2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 13:28:35 -0400
In-Reply-To: <CAHC9VhQKhoRt8yD4WAgD5tyqjY4bbp4Z4hr5cWfs-d6GJt0pjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Tue, 17 Jul 2012 12:25:28 -0400

> On Sat, Jul 14, 2012 at 4:08 PM, David Miller <davem@davemloft.net> wrote:
>> From: Lin Ming <mlin@ss.pku.edu.cn>
>> Date: Sun, 15 Jul 2012 01:22:30 +0800
>>
>>> It's caused by below code added in commit 15c45f7b.
>>>
>>>                 case CIPSO_V4_TAG_LOCAL:
>>>                         /* This is a non-standard tag that we only allow for
>>>                          * local connections, so if the incoming interface is
>>>                          * not the loopback device drop the packet. */
>>>                         if (!(skb->dev->flags & IFF_LOOPBACK)) {
>>>                                 err_offset = opt_iter;
>>>                                 goto validate_return_locked;
>>>                         }
>>
>> Paul please fix this, as shown 'skb' can easily be NULL in this
>> code path.
> 
> Just saw this ... I'll start looking into this today.

Thanks, sorry I messed up your email, I should have checked MAINTAINERS :)
