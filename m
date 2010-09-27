From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 23:42:02 -0700 (PDT)
Message-ID: <20100926.234202.241938788.davem@davemloft.net>
References: <20100926232530.GK12373@1wt.eu>
	<20100926.181202.28824153.davem@davemloft.net>
	<20100927053901.GL12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42804
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756320Ab0I0Glm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 02:41:42 -0400
In-Reply-To: <20100927053901.GL12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 27 Sep 2010 07:39:01 +0200

> On Sun, Sep 26, 2010 at 06:12:02PM -0700, David Miller wrote:
>> From: Willy Tarreau <w@1wt.eu>
>> Date: Mon, 27 Sep 2010 01:25:30 +0200
>> 
>> > Agreed. But that's not a reason for killing outgoing data that is
>> > being sent when there are some data left in the rcv buffer.
>> 
>> What alternative notification to the peer do you suggest other than a
>> reset, then?  TCP gives us no other.
> 
> I know, and I agree to send the reset, but after the data are correctly
> transferred. This reset's purpose is only to inform the other side that
> the data it sent were destroyed. It is not a requirement to tell it they
> were destroyed earlier or later. What matters is that it's informed they
> were destroyed.

So you want us to hold onto to the full connection state for however
long it takes to send the pending data just because your application
doesn't want to wait around to sink a pending newline character?

Is that what this boils down to?
