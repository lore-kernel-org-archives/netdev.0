From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 19:44:23 -0400
Message-ID: <46D604D7.6090200@psc.edu>
References: <46D5F32F.2070502@hp.com>	<20070829.153503.18295527.davem@davemloft.net>	<46D5FBF3.5050700@hp.com> <20070829.161528.38309258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53495 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbXH2Xom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 19:44:42 -0400
In-Reply-To: <20070829.161528.38309258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 29 Aug 2007 16:06:27 -0700
> 
>> I belive the biggest component comes from link-layer retransmissions. 
>> There can also be some short outtages thanks to signal blocking, 
>> tunnels, people with big hats and whatnot that the link-layer 
>> retransmissions are trying to address.  The three seconds seems to be a 
>> value that gives the certainty that 99 times out of 10 the segment was 
>> indeed lost.
>>
>> The trace I've been sent shows clean RTTs ranging from ~200 milliseconds 
>> to ~7000 milliseconds.
> 
> Thanks for the info.
> 
> It's pretty easy to generate examples where we might have some sockets
> talking over interfaces on such a network and others which are not.
> Therefore, if we do this, a per-route metric is probably the best bet.

This is exactly what I was thinking.  It might even help discourage 
users from playing with this setting who should not. ;)

   -John
