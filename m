From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 18:37:13 -0400
Message-ID: <46F1A499.5060809@garzik.org>
References: <20070918.151528.84360712.davem@davemloft.net>	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>	<46F19D25.2010403@garzik.org> <20070919.151144.59833230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36907 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753614AbXISWhR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 18:37:17 -0400
In-Reply-To: <20070919.151144.59833230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Wed, 19 Sep 2007 18:05:25 -0400
> 
>> That said, the 2-arg macro arg order is wrong.  It should be (reg,val) 
>> like tg3 and other drivers.
> 
> I actually wanted to mirror the ordering that
> writel() uses.
> 
> So the choice is arbitrary, either be consistent with
> our well established asm/io.h interfaces or a bunch
> of network driver :-)

IMO (val,reg) was always unnatural.  From looking at the register 
read/write interfaces people continually reinvent, humans definitely 
lean towards (reg,val).

	Jeff



