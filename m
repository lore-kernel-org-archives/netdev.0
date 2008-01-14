From: Ben Greear <greearb@candelatech.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 11:01:42 -0800
Message-ID: <478BB196.7050300@candelatech.com>
References: <478B99E6.2050800@hp.com> <478BA53B.9060504@candelatech.com> <478BA8D7.8050803@hp.com> <478BAF47.10607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:52337 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbYANTBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 14:01:44 -0500
In-Reply-To: <478BAF47.10607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Seger wrote:
> Ignore that last one as it was pointed out to me that we have both nic 
> installed on many of our systems and ethtool told me the one 
> associated with the nic is actually the broadcom one.
>
> version:        1.4.38 E1B1EC867DEEB8027B2DA0F
> license:        GPL
> description:    Broadcom NetXtreme II BCM5706/5708 Driver
Ok, we do a similar stats polling, though through a private ioctl I 
hacked into the kernel to
get the netdev->stats struct with a memcpy.  I haven't noticed any 
problems with counters
in the e1000 driver.   I haven't done enough testing on bcm drivers to 
ascertain whether it's
reliable or not w/regard to stats.

If you can reproduce the problem with e1000, it would be worth looking 
at the logic that prints
out the proc interface text for problems..and if you cannot, then maybe 
it's the bcm driver that
is at issue.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


