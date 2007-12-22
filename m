From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] [CORE]: datagram: basic memory accounting functions
Date: Fri, 21 Dec 2007 19:22:11 -0500
Message-ID: <476C58B3.8070301@redhat.com>
References: <47673299.3010301@redhat.com>	<20071220.034304.212231150.davem@davemloft.net>	<476B3EAE.4070809@redhat.com> <20071220.203105.209276041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbXLVAcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 19:32:41 -0500
In-Reply-To: <20071220.203105.209276041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Thu, 20 Dec 2007 23:18:54 -0500
> 
>>> Also, the memory accounting is done at different parts in
>>> the socket code paths for stream vs. datagram.  This is why
>>> everything is inconsistent, and, a mess.
>> Could you tell me more detailed information?
> 
> I think the core thing is that TCP and INET protocols call into
> the memory accounting internally, either inside their own code
> paths or with inet_*() helpers.
> 
> This is versus what we really want is everything happening via generic
> sk_foo() helpers.
> 
> If that's what's happening already, great, just consolidate the
> datagram vs. stream stuff and it should be good.

Thank you for the explanation.

I'll do my best.

Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.

