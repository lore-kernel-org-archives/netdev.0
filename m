From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/5] e1000e: Add interrupt moderation run-time ethtool
 interface
Date: Mon, 14 Apr 2008 13:09:42 -0700
Message-ID: <4803BA06.1000908@intel.com>
References: <20080414170557.23286.71580.stgit@localhost.localdomain>	<20080414170604.23286.86187.stgit@localhost.localdomain> <873apoutnt.fsf@basil.nowhere.org> <4803B20E.7090101@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12419 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbYDNUKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 16:10:53 -0400
In-Reply-To: <4803B20E.7090101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Andi Kleen wrote:
>> Auke Kok <auke-jan.h.kok@intel.com> writes:
>>
>>> The ethtool -c / -C interface can now be used to modify the
>>> irq moderation algorithm. This change does not require an
>>> adapter reset and can thus be used at all times. The adapter
>>> only supports changing/reading rx-usecs which has special
>>> values for 0, 1 and 3:
>>>
>>> 0 - no irq moderation whatsoever
>>> 1 - normal moderation favoring regular mixed traffic (default)
>>> 3 - best attempt at low latency possible at cost of CPU
>>
>> It would be nice if ethtool instead of having this as a obscure magic
>> number had a higher level "--low-latency" or similar parameter
>> (that could also potentially set similar settings on other NICs)
> 
> That would be fine with me -- that's one of the goals of ethtool:  make
> the setting of hardware-specific settings as generic and easy as possible.

yes I think that's a good addition, and might hook better into power management
and other high-level configuration tools.

I'm all for that :)

Auke
