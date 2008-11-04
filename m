From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Tue, 04 Nov 2008 22:42:28 +0100
Message-ID: <4910C1C4.3070309@trash.net>
References: <20081031132010.GA18895@ff.dom.local>	<20081102.003700.198708146.davem@davemloft.net>	<20081103082926.GA4698@ff.dom.local>	<490EDE79.6070500@trash.net>	<20081103090630.40b645d2@extreme>	<20081104095642.GA4498@ff.dom.local> <20081104082510.2dd57d04@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394AbYKDVmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 16:42:32 -0500
In-Reply-To: <20081104082510.2dd57d04@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> David, this makes sense to me, so please revert these two patches.
>> (Then, I think we're still at RFC stage.)
>>
>> Thanks.
>> Jarek P.
>>     
>
> Keep Jarek's patch, I am working on dummynet compatiable rate control.

I'm still wondering what these incompatibilies are, in verifiable terms.

The dummynet algorithm looks like a not particulary cleverly implemented
TBF, but I can't see why it would behave any differently than a suitably
configured Linux TBF (cell size == 1) except for implementation differences
outside its scope (clock, timers etc).


