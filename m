From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] qlge: Add watchdog timer.
Date: Thu, 04 Feb 2010 13:32:17 -0800 (PST)
Message-ID: <20100204.133217.265071373.davem@davemloft.net>
References: <20100204200603.GB9938@linux-ox1b.qlogic.org>
	<20100204.122931.189315763.davem@davemloft.net>
	<20100204211929.GC9938@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756267Ab0BDVcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 16:32:05 -0500
In-Reply-To: <20100204211929.GC9938@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 4 Feb 2010 13:19:29 -0800

>> Did the timer every fire more than once in your testing?
>> 
>> Don't you need to re-setup the expiration period before
>> adding it again?
> 
> It does fire repeatedly but I should have put in the new expiration
> period.  I added some prints to the timer and without resetting the
> expiration the timer would pop faster, but still less than 5 seconds.
> I've added the expiration here and see very even pops on 5 second
> intervals.

Of course it pops faster, if you don't reset the expiration
period it is "right now". :-)

I'll apply this new version, thanks.
