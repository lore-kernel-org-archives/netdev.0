From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] xtsonic: convert to net_device_ops
Date: Mon, 13 Apr 2009 16:19:35 -0700 (PDT)
Message-ID: <20090413.161935.118273968.davem@davemloft.net>
References: <20090411173019.GA16999@orion>
	<20090413.151904.74427510.davem@davemloft.net>
	<a4423d670904131612pacc4f7fj4e8d03612a41a9b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752342AbZDMXTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 19:19:44 -0400
In-Reply-To: <a4423d670904131612pacc4f7fj4e8d03612a41a9b8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Tue, 14 Apr 2009 03:12:27 +0400

> 2009/4/14 David Miller <davem@davemloft.net>:
>> From: Alexander Beregalov <a.beregalov@gmail.com>
>> Date: Sat, 11 Apr 2009 21:30:19 +0400
>>
>>> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
>>
>> Applied.
> 
> Thanks David.
> 
> It seems build should not fail with !CONFIG_COMPAT_NET_DEV_OPS anymore.
> Perhaps it can be changed to "default n" in next release (-next and 2.6.31) ?

I think we probably do that, sure.  I'll try to remember to do
this next time I merge net-2.6 into net-next-2.6

And after a few weeks of -next exposure I think we can remove
the option and protected code entirely.
