From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Thu, 25 Aug 2011 16:23:07 -0400
Message-ID: <1314303787.2329.1.camel@mojatatu>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	 <1312808784.17202.39.camel@mojatatu>
	 <1312809524.4372.29.camel@jlt3.sipsolutions.net>
	 <CA+mtBx8mb0pAqVH19WK=e9LuLeyvnNTybROOURD2Rg6UtYe+bw@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:50085 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab1HYUXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 16:23:14 -0400
Received: by vxi9 with SMTP id 9so2023939vxi.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 13:23:13 -0700 (PDT)
In-Reply-To: <CA+mtBx8mb0pAqVH19WK=e9LuLeyvnNTybROOURD2Rg6UtYe+bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-08-25 at 08:29 -0700, Tom Herbert wrote:

> BQL is dynamic, and will increase the queue limit more aggressively
> than decrease it.  So for instance, we can track the largest queue
> needed over 30 seconds which should be stable in the presence even in
> the presence of fluctuating bandwidth.  The thing that worries me is
> rather the HW queues conform to the queue characteristics described in
> the patch.  If transmit completions are random and not regular, BQL
> probably can't function well.
> 

I think thats the challenge ;-> I wouldnt say it is random, but if my
understanding is correct the effect is a factor of number of stations
etc.

> If you'd like to bring this up on some wireless devices that would be
> great, I don't have easy access to any right now, but I can try to
> help otherwise.

I am most curious as well...

cheers,
jamal
