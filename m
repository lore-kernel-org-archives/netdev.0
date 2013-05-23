From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_tbf: segment too big GSO packets
Date: Thu, 23 May 2013 00:07:14 -0700 (PDT)
Message-ID: <20130523.000714.1429138700064965816.davem@davemloft.net>
References: <1369101790.3301.206.camel@edumazet-glaptop>
	<1369160206.3301.245.camel@edumazet-glaptop>
	<20130521203945.GA1634@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, ben@decadent.org.uk
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3EWHHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:07:15 -0400
In-Reply-To: <20130521203945.GA1634@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 21 May 2013 22:39:45 +0200

> Tue, May 21, 2013 at 08:16:46PM CEST, eric.dumazet@gmail.com wrote:
>>From: Eric Dumazet <edumazet@google.com>
>>
>>If a GSO packet has a length above tbf burst limit, the packet
>>is currently silently dropped.
>>
>>Current way to handle this is to set the device in non GSO/TSO mode, or
>>setting high bursts, and its sub optimal.
>>
>>We can actually segment too big GSO packets, and send individual
>>segments as tbf parameters allow, allowing for better interoperability.
>>
>>Signed-off-by: Eric Dumazet <edumazet@google.com>
>>Cc: Ben Hutchings <ben@decadent.org.uk>
>>Cc: Jiri Pirko <jiri@resnulli.us>
>>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks everyone.
