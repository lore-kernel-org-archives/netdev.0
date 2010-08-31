From: David Miller <davem@davemloft.net>
Subject: Re: PF_NETLINK, SOCK_DGRAM, 2 => EPROTONOSUPPORT
Date: Tue, 31 Aug 2010 09:50:04 -0700 (PDT)
Message-ID: <20100831.095004.173857635.davem@davemloft.net>
References: <alpine.LNX.2.00.1008301158360.28658@er-systems.de>
	<20100830.190619.91328359.davem@davemloft.net>
	<alpine.LNX.2.00.1008311213300.3405@er-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tv@lio96.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38340
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753335Ab0HaQtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 12:49:47 -0400
In-Reply-To: <alpine.LNX.2.00.1008311213300.3405@er-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Voegtle <tv@lio96.de>
Date: Tue, 31 Aug 2010 12:15:26 +0200 (CEST)

> On Mon, 30 Aug 2010, David Miller wrote:
> 
>> From: Thomas Voegtle <tv@lio96.de>
>> Date: Mon, 30 Aug 2010 12:02:51 +0200 (CEST)
>>
>>> Was this intended, that this code snippet doesn't work this way
>>> anymore or is this just a bug?
>>
>> It's an unintended regression.
>>
>> But nobody noticed it, because almost no-one uses NETLINK_USER.
>>
>> This might fix it, give it a test:
> 
> 
> Yes, that fixes it. Tested with 2.6.35.4 and 2.6.36-rc3.

Thanks for testing.
