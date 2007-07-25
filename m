From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [-mm patch] one e1000 driver should be enough for everyone
Date: Wed, 25 Jul 2007 08:21:10 -0700
Message-ID: <46A76A66.9000304@intel.com>
References: <20070725040304.111550f4.akpm@linux-foundation.org> <20070725133650.GB3572@stusta.de> <46A754C7.9080004@garzik.org> <20070725144615.GC3572@stusta.de> <46A7669C.5010104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753741AbXGYPVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 11:21:15 -0400
In-Reply-To: <46A7669C.5010104@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Adrian Bunk wrote:
>> I found the discussion, and Christoph's e1000e sounds like the best name 
>> ("new" doesn't say whether it's a new driver for old hardware or a 
>> driver for new hardware).
> 
> Yeah, I think "e1000new" is a lame name.

Moreover, Andrew should probably just drop this driver from -mm for now.

> e1000e is good, or even e1001e if we wanted even more symmetry :)

I'm working on "e1000e" right now...

>> No problem for me, but this obviously implies that global code in the 
>> new driver has to be renamed.
> 
> Yes.  A global namespace is a global namespace.

yes, these are some of the kinks I still need to address. Allthough minor, it's 
going to take me some time to get it to the first step before I want to submit 
it (patience :))

>> And please ensure that they will always support distinct PCI IDs, or 
>> there will be the following common pattern if both drivers support
>> a card:
> 
> IIRC I think Auke said there is some minor PCI ID overlap that must be 
> addressed in the transition.  Disappointing and it raises transition 
> issues, but that's the way the split falls out naturally AFAICS.

I'll submit it with only ich9 id's at first, but it will be able to drive (sysfs 
bind) to some other devices too. This allows me to keep an eye out on the future 
structure that I want to give it without removing too much code that I might 
then later have to add back.

Auke
