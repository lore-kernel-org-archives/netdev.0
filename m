From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fec: Add support for Coldfire M5441x enet-mac.
Date: Thu, 07 Jun 2012 14:47:47 -0700 (PDT)
Message-ID: <20120607.144747.1809368718789038860.davem@davemloft.net>
References: <201206061006.21288.sfking@fdwdc.com>
	<4FCF949D.7060402@computer.org>
	<201206061305.48893.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.ceuleers@computer.org, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org, gerg@snapgear.com
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932994Ab2FGVrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 17:47:48 -0400
In-Reply-To: <201206061305.48893.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven King <sfking@fdwdc.com>
Date: Wed, 6 Jun 2012 13:05:48 -0700

> On Wednesday 06 June 2012 10:34:21 am Jan Ceuleers wrote:
>> On 06/06/2012 07:06 PM, Steven King wrote:
>> > Add support for the Freescale Coldfire M5441x; as these parts have an
>> > enet-mac, add a quirk to distinguish them from the other Coldfire parts
>> > so we can use the existing enet-mac support.
>>
>> Stephen,
>>
>> You are activating certain functionality based on whether M5441x is
>> defined. But where is this being defined? Should this not be added in a
>> Kconfig somewhere as a platform option?
> 
> Yes.  Hopefully, once I send Greg my updated patches to add support for the 
> m5441x, then it will be a selection in the m68k port.  I just happened to 
> have these ready to go after David chastised me for sending them too late in 
> the last merge cycle...

I don't see any point in applying this before the necessary infrastructure
this depend upon is in the tree.

Therefore I'm not applying this.
