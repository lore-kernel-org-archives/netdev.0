From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.38 dev_watchdog WARNING
Date: Tue, 19 Apr 2011 11:20:48 -0700
Message-ID: <4DADD280.70104@candelatech.com>
References: <4DADC8F2.9050700@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37190 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab1DSSUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 14:20:53 -0400
In-Reply-To: <4DADC8F2.9050700@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2011 10:40 AM, Tim Gardner wrote:
> I'm seeing a lot of these kinds of bugs: WARNING: at
> /build/buildd/linux-2.6.38/net/sched/sch_generic.c:256
> dev_watchdog+0x213/0x220()
>
> The kernel is 2.6.38.2 plus Ubuntu cruft.
>
> A spot check of the 200+ hits on this string indicates they are
> primarily due to these drivers:
>
> ipheth
> atl1c
> sis900
> r8169
>
> As far as I can tell the warning happens when link is down on the media
> (and has never been link UP) and are sent a transmit packet which never
> completes. Is there a net/core or net/sched requirement to which these
> drivers do not conform ? Are they not correctly indicating link status?

r8169 doesn't report link right for me...

No idea about the rest.

Ben

>
> rtg


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

