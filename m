From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: SFQ depth limit
Date: Thu, 24 Jul 2008 09:49:08 +0000
Message-ID: <20080724094908.GA3946@ff.dom.local>
References: <200806282202.59581.denys@visp.net.lb> <20080629191113.GA8817@ami.dom.local> <20080723.213443.37820788.davem@davemloft.net> <48884133.8070301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.234]:6876 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbYGXJoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 05:44:03 -0400
Received: by hu-out-0506.google.com with SMTP id 28so8477161hub.21
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 02:44:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48884133.8070301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 10:45:39AM +0200, Patrick McHardy wrote:
> David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Sun, 29 Jun 2008 21:11:13 +0200
>>
>>   
>>> sch_sfq: dump a real number of flows
>>>
>>> Dump the "flows" number according to the number of active flows
>>> instead of repeating the "limit".
>>>     
>>
>> Looks reasonable, applied, thanks Jarek.
>
> I'm not sure we should do this, this removes the symetry between
> ->init/change and ->dump. Its not a big deal in this case since
> flows is unused in ->init anyway, but still its a not so nice
> precedent. Such things should normally be put in the statistics.
>

Hmm... I didn't even notice this. But I guess, this patch didn't
introduce this precedent since this non-config "flow" was dumped
before. Btw., I can see e.g. direct_pkts in htb_dump() which looks
like similar precedent. IMHO, printing the same thing 2x under
different names is worse precedent. Anyway, this patch isn't any
big deal, so I can send a revert.

Thanks,
Jarek P.
