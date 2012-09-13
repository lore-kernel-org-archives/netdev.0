From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce
 schema
Date: Thu, 13 Sep 2012 17:37:27 -0400 (EDT)
Message-ID: <20120913.173727.314155374058895289.davem@davemloft.net>
References: <1347568971.13258.19.camel@deadeye.wl.decadent.org.uk>
	<20120913.164645.1268091771093604148.davem@davemloft.net>
	<1347570650.13258.40.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147Ab2IMVh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:37:29 -0400
In-Reply-To: <1347570650.13258.40.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 13 Sep 2012 22:10:50 +0100

> On Thu, 2012-09-13 at 16:46 -0400, David Miller wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Thu, 13 Sep 2012 21:42:51 +0100
>> 
>> Well written NAPI drivers never need to disable hardware interrupts
>> in their ->poll() method and it's callers, neither should you.
> 
> Perhaps you should get round to reviewing netpoll, because it does
> exactly this.

Then I don't understand the point you're trying to make.

Hardware interrupt disabling has absolutely no place in the
NAPI polling fast paths.

If NAPI drivers can't be implemented without hardware interrupt
toggling in ->poll(), we've failed.
