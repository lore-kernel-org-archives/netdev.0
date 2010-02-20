From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Fix sysctl restarts...
Date: Fri, 19 Feb 2010 16:02:59 -0800 (PST)
Message-ID: <20100219.160259.266645466.davem@davemloft.net>
References: <m1ocjksssg.fsf@fess.ebiederm.org>
	<20100219.154140.77047519.davem@davemloft.net>
	<m1aav4srpe.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052Ab0BTACm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 19:02:42 -0500
In-Reply-To: <m1aav4srpe.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 19 Feb 2010 15:58:53 -0800

> David Miller <davem@davemloft.net> writes:
> 
> 2> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Fri, 19 Feb 2010 15:35:27 -0800
>>
>>> When we I fixed the deadlock that can happen if you write to forwarding
>>> while removing the device.  The deadlock was fixed, the restart worked
>>> but I somehow missed the fact that proc_dointvec modifies state and so
>>> defeated the change detection.  *embarrassing*
>>
>> Ok, I'll have to push these around to Linus and a couple -stable
>> releases.
> 
> The second patch fixes an issue which isn't quite as old.
> 
> I caught it when I was looking for other rtnl_lock issues that
> I may have missed.  Thankfully the worst sysfs does is re-read
> the string from userspace on a restart so none of the sysfs
> rtnl_trylock cases have a nasty deadlock associated.
> 
> Eric
> 
> 
> commit a160ee69c6a4622ed30c377a978554015e9931cb
> Author: Johannes Berg <johannes@sipsolutions.net>
> Date:   Mon Oct 5 02:22:23 2009 -0700

So the second patch needs to go to less -stable releases than the
other one.  Thanks for the info.
