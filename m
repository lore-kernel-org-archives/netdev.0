From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 09:49:20 +0400
Message-ID: <20080922054918.GA31099@2ka.mipt.ru>
References: <20080922041929.GA20165@2ka.mipt.ru> <20080921.212724.193719407.davem@davemloft.net> <20080922044051.GA583@2ka.mipt.ru> <20080921.220605.129235191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:45269 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481AbYIVFuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 01:50:03 -0400
Content-Disposition: inline
In-Reply-To: <20080921.220605.129235191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 10:06:05PM -0700, David Miller (davem@davemloft.net) wrote:
> Because datagram sockets are completely different from stream sockets.
> 
> You program them differently, segmentation is made by the socket user
> not within by the protocol itself.
> 
> sendfile() should behave in a way congruent to the other data transfer
> APIs of the BSD socket layer.

So effectively you are saying, that sendfile() is just a pure send(),
but with diferent arguments? I.e. it is not supposed to send the whole
data it points to, but as much as possible according to send() standard?

Well, it may be a right or wrong decision, and in my opinion sendfile()
is very diferent than send() since it should require the whole data to
be sent, i.e. being like a loop of send()s, but since sendfile() is
effectively a very new approach, it could have different behaviour
rules.

Because of this, Johann, this patch will not be applied, but thanks a
lot for your work, we made a clear meaning on interface usage.

-- 
	Evgeniy Polyakov
