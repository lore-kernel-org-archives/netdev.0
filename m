From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: intel 82571EB gigabit fails to see link on 2.6.20-rc5 in-tree
 e1000 driver (regression)
Date: Wed, 17 Jan 2007 15:56:11 -0800
Message-ID: <45AEB79B.2010205@intel.com>
References: <20070117190448.A20184@mail.kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Allen Parker <parker@isohunt.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5479 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254AbXAQX4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 18:56:15 -0500
To: Adam Kropelin <akropel1@rochester.rr.com>
In-Reply-To: <20070117190448.A20184@mail.kroptech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adam Kropelin wrote:
>> Allen Parker wrote:
>>> Allen Parker wrote:
>>>>  From what I've been able to gather, other Intel Pro/1000 chipsets 
>>>> work fine in 2.6.20-rc5. If the e1000 guys need any assistance 
>>>> testing, I'll be more than happy to volunteer myself as a guinea pig 
>>>> for patches.
>>> I wasn't aware that I was supposed to post this as a regression, so 
>>> changed the subject, hoping that someone will pick this up and run with 
>>> it. Primary issue being that link is not seen on this chipset under 
>>> 2.6.20-rc5 via in-tree e1000 driver, despite multiple cycles of ifconfig 
>>> $eth up && ethtool $eth | grep link && ifconfig $eth down. Tested on 2 
>>> machines with identical hardware.
>> I asked Allen to report this here. I'm working on the issue as we speak
>> but for now I'll treat the link issue as a known regression once I 
>> confirm it. If others have seen it then I'd like to know ASAP of course
> 
> I am experiencing the no-link issue on a 82572EI single port copper
> PCI-E card. I've only tried 2.6.20-rc5, so I cannot tell if this is a
> regression or not yet. Will test older kernel soon.
> 
> Can provide details/logs if you want 'em.

we've already established that Allen's issue is not due to the driver and caused by 
interrupts being mal-assigned on his system, possibly a pci subsystem bug. You also have 
a completely different board (82572EI instead of 82571EB), so I'd like to see the usual 
debugging info as well as hearing from you whether 2.6.19.any works correctly.

On top of that I posted a patch to rc5-mm yesterday that fixes a few significant bugs in 
the rc5-mm driver, so please apply that patch too before trying, so we're not wasting 
our time finding old bugs ;)

Cheers,

Auke
