From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 09:05:19 -0700
Message-ID: <44EDCE3F.9010208@intel.com>
References: <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com> <44EDCCE2.3030408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, Jeff Kirsher <tarbal@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>, Jeff@lime.pobox.com,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28241 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030305AbWHXQLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 12:11:31 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44EDCCE2.3030408@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Michael Chan wrote:
>> Jeff Kirsher wrote:
>>
>>> The old way of setting autonegotiation was using the following command:
>>> ethtool -s ethx speed 100 duplex full auto on
>>> now the command would be
>>> ethtool -s ethx auto on advertise 0x08
>>> both commands would result in only advertising 100 FULL.
>>>
>>> There still needs to be a change made to the man file to reflect the
>>> change in the behavior of ethtool, which I have not done.  But this
>>> patch will allow for greater flexibility in setting autonegotiation
>>> speeds.
>>
>> It is more flexible, but less intuitive.  The user now has to
>> remember hex values instead of the more intuitive speed and
>> duplex.  Perhaps we can keep the old method of using speed and
>> duplex, while adding the new method of specifying hex values? 
> 
> the patch doesn't remove the old method, it merely adds a second path to 
> the speed/duplex setting. Using the "old" syntax will still work.

hmm, I'm not saying I was wrong there and that if the patch did remove the old 
method there will certainly be a new patch that keeps the old functionality.

okay okay, I am ;)

Auke
