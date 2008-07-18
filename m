From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG, NET] deadlock tearing down a bridged interface
Date: Fri, 18 Jul 2008 08:44:58 -0700
Message-ID: <4880BA7A.3020909@candelatech.com>
References: <20080718073724.GA5802@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [208.74.158.172] ([208.74.158.172]:54603 "EHLO ns3.lanforge.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755255AbYGRQ0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 12:26:53 -0400
In-Reply-To: <20080718073724.GA5802@disturbed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Chinner wrote:
> Folks,
>
> I just deadlocked networking on a 2.6.24 kernel. Basically I
> was trying to restart the bridge interface I use for UML sessions
> because it wasn't passing packets. This happens occasionally
> when I leave a UML session too long in gdb, so I bounced the
> bridge to get it working again.
>   
We have been chasing a refcount bug in 2.6.25 that only happens when
IPv6 module is loaded.  If you are not actually using ipv6, try removing 
it's
module from your /lib/modules/* directory and see if that fixes your 
problem.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


