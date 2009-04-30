From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
 sk_buff state
Date: Thu, 30 Apr 2009 09:46:14 -0700 (PDT)
Message-ID: <20090430.094614.13889468.davem@davemloft.net>
References: <20090429222809.GA1949@cuplxvomd02.corp.sa.net>
	<20090429.154406.231161665.davem@davemloft.net>
	<20090430163200.GC15170@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762765AbZD3QqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 12:46:20 -0400
In-Reply-To: <20090430163200.GC15170@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <dvomlehn@cisco.com>
Date: Thu, 30 Apr 2009 09:32:00 -0700

> I think the size is very doable. Only two bits are needed to encode
> the state so the ability to check the state isn't an issue. The
> other piece, though, is recording enough information to be able to
> pinpoint the problem.

It's not my job to design this thing for you, but I guess that's what
I have to do to get you to think out of the box a little bit :-/

Maintain a table, which is only recorded into when the debugging
feature is enable (via sysctl or whatever) which remembers this stuff.

That way nobody eats the space or time overhead unless the debugging
feature is enabled.

Wow, I had to use every brain cell I have to come up with that one!

