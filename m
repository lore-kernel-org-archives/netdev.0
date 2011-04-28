From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Thu, 28 Apr 2011 13:42:41 -0700 (PDT)
Message-ID: <20110428.134241.70176095.davem@davemloft.net>
References: <20110426013512.GA2031@mcarlson.broadcom.com>
	<1303841530.24299.37.camel@Joe-Laptop>
	<20110427162821.GA9762@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, mchan@broadcom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752243Ab1D1UnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:43:15 -0400
In-Reply-To: <20110427162821.GA9762@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 27 Apr 2011 09:28:21 -0700

> On Tue, Apr 26, 2011 at 11:12:10AM -0700, Joe Perches wrote:
>> Using a bitmap instead of separate u32 flags allows a consistent, simpler
>> and more extensible mechanism to determine capabilities.
>> 
>> Convert bitmasks to enum.
>> Add tg3_flag, tg3_flag_clear and tg3_flag_set.
>> Convert the flag & bitmask tests.
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> I looked through it and didn't see any problems.  I've queued
> Michael Chan's suggestion into my queue.
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

I've applied Joe's change to net-next-2.6, thanks everyone.
