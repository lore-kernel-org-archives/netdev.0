From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6:fix an oops when force unload ipv6 module
Date: Fri, 18 Dec 2009 20:25:33 -0800 (PST)
Message-ID: <20091218.202533.245395320.davem@davemloft.net>
References: <4B29BECD.1040004@cn.fujitsu.com>
	<20091216215135.37d89adc@nehalam>
	<4B29D2B3.80303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbZLSEZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:25:32 -0500
In-Reply-To: <4B29D2B3.80303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Thu, 17 Dec 2009 14:41:55 +0800

> Stephen Hemminger wrote:
>> On Thu, 17 Dec 2009 13:17:01 +0800
>> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>> 
>>> When I do an ipv6 module force unload,I got the following oops:
>>> #rmmod -f ipv6
>>>
>> 
>> Okay, but force unloading IPV6 leaves some dangling control
>> sockets that will crash in other ways.
>> 
> 
> Yes,but if we make sure that there is no other services and modules
> using IPV6,it can be force unloaded without causing other problems.

Yes, the cleanup code that is there should be correct.

Applied, thank you.
