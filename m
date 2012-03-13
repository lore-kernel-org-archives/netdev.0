From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 15:59:06 -0700 (PDT)
Message-ID: <20120313.155906.1275225317793926230.davem@davemloft.net>
References: <20120313072643.GA32306@hostway.ca>
	<CADVnQynM5F=B60-7AMFHn0A9g-jvcBzo+dSg-C0isDBo_UMyjw@mail.gmail.com>
	<1331660251.4449.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, sim@netnation.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760584Ab2CMW7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 18:59:11 -0400
In-Reply-To: <1331660251.4449.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Mar 2012 10:37:31 -0700

> On Tue, 2012-03-13 at 12:44 -0400, Neal Cardwell wrote:
> 
>> Yes, exactly. 3.2.9 and 3.2.10 have
>> daef52bab1fd26e24e8e9578f8fb33ba1d0cb412 but not the
>> 4648dc97af9d496218a05353b0e442b3dfa6aaab that fixes the resulting
>> issue with sacked_out going negative, and these lines you've flagged
>> are exactly the symptoms we'd expect because of that. The fix is
>> queued up for the -stable series already, so it should be in 3.2.11, I
>> presume. The fix is already in 3.3-rc7.
> 
> 3.2.12 more probably, as 3.2.11 is a single build fix

The syncookie regression fix isn't even pushed to Linus's tree yet,
and once it's there it still needs to cook for a few more days before
I'm willing to sent it to -stable.
