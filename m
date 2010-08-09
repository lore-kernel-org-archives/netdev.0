From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: Provide details on watchdog timeout.
Date: Mon, 09 Aug 2010 13:08:47 -0700 (PDT)
Message-ID: <20100809.130847.189707542.davem@davemloft.net>
References: <1281381401-5554-1-git-send-email-greearb@candelatech.com>
	<20100809152820.26dbffc1@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55154
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755532Ab0HIUI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:08:28 -0400
In-Reply-To: <20100809152820.26dbffc1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 9 Aug 2010 15:28:20 -0400

> On Mon,  9 Aug 2010 12:16:41 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
>> This also makes it printed under net_ratelimit instead
>> of WARN_ON_ONCE.  The backtrace never helped me much.
>> 
>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>>
> 
> Please don't remove the WARN_ because it is used by oops.kernel.org
> automated tracking.

Yes, please don't change this, there are automated tools that
know about what this thing spits out and yes the backtrace
needs to be there.

