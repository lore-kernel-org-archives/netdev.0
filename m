From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] bnx2: Print warning when unable to allocate the
 full SKB/page ring.
Date: Thu, 03 Dec 2009 14:05:04 -0800 (PST)
Message-ID: <20091203.140504.190401557.davem@davemloft.net>
References: <1259869595-6450-3-git-send-email-mchan@broadcom.com>
	<20091203.130821.253017587.davem@davemloft.net>
	<1259876960.8991.12.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55929
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751778AbZLCWE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:04:57 -0500
In-Reply-To: <1259876960.8991.12.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 3 Dec 2009 13:49:20 -0800

> 
> On Thu, 2009-12-03 at 13:08 -0800, David Miller wrote:
>> Applied, but I would rate limit this thing.
>> 
>> It could especially be problematic if this condition is
>> triggered when the device is being used for netconsole.
>> 
> 
> We only do the printk() during init. time if we cannot allocate buffers
> for the whole ring.  printk() is not used at all during run-time.

Thanks for clearing that up.  I mistakedly thought this was for
the buffers not the ring.
