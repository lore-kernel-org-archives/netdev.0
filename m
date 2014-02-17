From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast
 address
Date: Mon, 17 Feb 2014 14:19:49 -0500 (EST)
Message-ID: <20140217.141949.1387848185062797150.davem@davemloft.net>
References: <20140217.001545.981758741332832466.davem@davemloft.net>
	<20140217093231.GA4609@cpaasch-mac>
	<CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, hannes@stressinduktion.org,
	fx.lebail@yahoo.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaBQTTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:19:52 -0500
In-Reply-To: <CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Mon, 17 Feb 2014 14:02:02 +0400

> Hello!
> 
> On Mon, Feb 17, 2014 at 1:32 PM, Christoph Paasch
> <christoph.paasch@uclouvain.be> wrote:
>> I don't have strong opinions for or against this patch.
>>
>> I was only involved in the original thread because F-X claimed that
>> draft-iab-anycast-arch-implications (now RFC 7094) allows the use of anycast
>> addresses for TCP, which is not what RFC 7094 is saying. There is no
>> recommendation concerning TCP in the RFC and the situation is rather unclear.
> 
> The same is here.
> 
> Using anycast as source or bind address, why not?
> 
> Use of anycast with TCP? Logically impossible, ergo prohibited.
> If someone wants to play with fire, the option can be left hidden behind
> a sysctl disabled by default.

Agreed.
