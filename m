From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Thu, 16 Jul 2009 19:48:46 -0700 (PDT)
Message-ID: <20090716.194846.58845712.davem@davemloft.net>
References: <65634d660907131504u35154059m5934cca3cb9363e0@mail.gmail.com>
	<20090714.123313.186658126.davem@davemloft.net>
	<65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933777AbZGQCsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 22:48:41 -0400
In-Reply-To: <65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 14 Jul 2009 16:28:01 -0700

> Using the Toeplitz hash in steering lookup has given us about 10% more
> maximum pps (2 different NICs), and we haven't really noticed negative
> effects because of the extra descriptor overhead-- so I'm not going to
> give up on it too easily!

Do you have any idea why?  Does Toeplitz distribute better?
If so, that could be merely because either:

1) Our modulus avoidance scheme somehow decreases the distribution
   features of the hash

2) The way we feed data into the hash has a similar effect

It's worth checking out.

>> I had no choice, as I'm giving a presentation on this stuff tomorrow
>> night here in NYC :-)
> 
> Cool, do you happen to have slides.... :-)

I'll post them soon.
