From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 11:21:03 -0700 (PDT)
Message-ID: <20101026.112103.212686377.davem@davemloft.net>
References: <AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
	<20101026.105524.116376168.davem@davemloft.net>
	<AANLkTi=Wp83HtQHXG0YEBjmctQYDu9Y4j+O9==_URy_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36300
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932875Ab0JZSUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:20:40 -0400
In-Reply-To: <AANLkTi=Wp83HtQHXG0YEBjmctQYDu9Y4j+O9==_URy_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 11:02:45 -0700

> On Tue, Oct 26, 2010 at 10:55 AM, David Miller <davem@davemloft.net> wrote:
>>> Are there? For wifi you could look at the SSID (though even that is no
>>
>> I'm saying to check the AP's MAC.
> 
> Ah yes, that works better. But for wired? Or do you think it should be
> fixed only for wifi?

For now the case where it is most important to do something, and
the situation is common, seems to be wireless.

BTW, we already have a NETDEV_NOTIFY_PEERS notifier for faster
failover.  It's used in ipv4 to generate gratuitous ARPs.

Maybe it could be used for your case too somehow.  Just an idea.

