From: David Miller <davem@davemloft.net>
Subject: Re: oopses since "net: Optimize memory usage when splicing from
 sockets"
Date: Thu, 30 Apr 2009 05:43:39 -0700 (PDT)
Message-ID: <20090430.054339.84716557.davem@davemloft.net>
References: <20090430124036.GN14729@mail.wantstofly.org>
	<20090430.054040.31760584.davem@davemloft.net>
	<20090430124542.GO14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbZD3Mnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:43:45 -0400
In-Reply-To: <20090430124542.GO14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 30 Apr 2009 14:45:42 +0200

> On Thu, Apr 30, 2009 at 05:40:40AM -0700, David Miller wrote:
> 
>> > With your patch, at least the oops is gone, and I guess it makes
>> > sense and looks correct, so:
>> > 
>> > 	Tested-by: Lennert Buytenhek <buytenh@wantstofly.org>
>> 
>> Thanks for testing Lennert.
>> 
>> I'll queue this up for -stable too.
> 
> I don't see this in 2.6.29, since the offending commit was merged
> after 2.6.29 AFAICS?

You're right, it's not needed there.  The optimization went into
2.6.30-rcX only.

Thanks!

