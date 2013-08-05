From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lto, wan/sbni: Make inline assembler symbols visible
 and assembler global
Date: Mon, 05 Aug 2013 16:09:21 -0700 (PDT)
Message-ID: <20130805.160921.1993558223692145813.davem@davemloft.net>
References: <1375741094-8166-1-git-send-email-andi@firstfloor.org>
	<20130805.153323.276242626385124232.davem@davemloft.net>
	<20130805230535.GP19750@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab3HEXJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:09:22 -0400
In-Reply-To: <20130805230535.GP19750@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 6 Aug 2013 01:05:35 +0200

> On Mon, Aug 05, 2013 at 03:33:23PM -0700, David Miller wrote:
>> From: Andi Kleen <andi@firstfloor.org>
>> Date: Mon,  5 Aug 2013 15:18:14 -0700
>> 
>> > From: Andi Kleen <ak@linux.intel.com>
>> > 
>> > - Inline assembler defining C callable code has to be global
>> > - The function has to be visible
>> > 
>> > Do this in wan/sbni
>> > 
>> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
>> 
>> Please just make it use the standard lib/ CRC routines instead.
> 
> The problem is I don't have this hardware, and I don't think
> I can do such a change without testing it.

I say you can, having assembly in here for something as fundamental
as this is pointless.
