From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Sat, 7 Jun 2008 18:33:12 -0700
Message-ID: <20080608013312.GA19130@synapse.neuralscape.com>
References: <20080607183106.GA14526@synapse.neuralscape.com> <F72FA20C31DD4F4C997B91C5B3690A090B146108@hqemmail07.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	manfred@colorfullife.com, netdev@vger.kernel.org
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.144.200.82] ([198.144.200.82]:46903 "EHLO neuralscape.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755441AbYFHBeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2008 21:34:11 -0400
Content-Disposition: inline
In-Reply-To: <F72FA20C31DD4F4C997B91C5B3690A090B146108@hqemmail07.nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 07, 2008 at 12:28:35PM -0700, Ayaz Abdulla wrote:
> Karen,
> 
> Is the switch in forced mode? That would explain the mismatch. I can
> look into a fix to workaround the hang.
> 
> Please open a bugzilla bug as you recommend. Emails get deleted after a
> couple of weeks and it is better to have a permanent location to track
> issues like this.
> 
> Thanks,
> Ayaz

Hi Ayaz,
Thank you for responding.
No, the switch vlan port is configured for 100 Mb autoneg on. The NIC
is configured with a boot time script using ethtool for 100 Mb autoneg on.
The result is always the same. The switch port links at 100 Mb full duplex,
and the NIC links at 100 Mb half duplex.

One can configure the NIC for 100 Mb autoneg off full duplex. And then
the link mismatch does not occur. And I have never seen the failure
in this case. But end users in the field sometimes just don't pay attention
and end up with the mismatch, so the failure was first discovered by an
end user.

At 1000 Mb, the link mismatch never happens. I've only seen this failure at
100 Mb.

The bug has been opened with ID 10885. I don't work with that project anymore,
but I'll definitely follow up with the appropriate folks, when this issue
is resolved. I am sure they will be very interested in a resolution.

Thanks,
Karen
-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
