From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: time stamps of skb packets in NF_HOOKS callbacks
Date: Thu, 17 Aug 2006 19:58:35 +0400
Message-ID: <20060817155835.GA11898@2ka.mipt.ru>
References: <ada605fb0608170737m4c0096c4u33a70dcf37e09df8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32993 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932549AbWHQP6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 11:58:39 -0400
To: John Que <qwejohn@gmail.com>
Content-Disposition: inline
In-Reply-To: <ada605fb0608170737m4c0096c4u33a70dcf37e09df8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 05:37:15PM +0300, John Que (qwejohn@gmail.com) wrote:
> Hello,
> I am using NF_HOOKS (a "PRE_ROUTING" hook).
> When I try to print the time stamps (sec and usec) of skb packets
> which I recieve
> in the hook callback I get 0. Other skb fileds are correct.
> According to my understanding, the time stamp should be updated
> when the packet is received. Isn't it so ? Any idea why am I getting
> "0" for tstamp fields (tstamp is a field in sk_buff and is  an intance
> of skb_timeval).

Timestamps are disabled by default, if you have sockets which enable
SO_TIMESTAMP or netfilter queue target and other agents which can enable
it, you will see updated values in skb->tstamp.

-- 
	Evgeniy Polyakov
