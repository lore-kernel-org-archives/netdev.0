From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Thu, 01 Mar 2007 08:55:34 -0800
Message-ID: <45E70586.60201@intel.com>
References: <45E64080.4070004@mvista.com> <45E645F4.2090403@intel.com> <45E65DCF.8050903@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ingo Molnar <mingo@elte.hu>
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28860 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965395AbXCAQ4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 11:56:12 -0500
In-Reply-To: <45E65DCF.8050903@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Huth wrote:
> Kok, Auke wrote:
>> Mark Huth wrote:
>>> Current e1000_xmit_frame spews raw interrupt disabled nag messages when
>>> used with RT kernel patches.  This patch uses spin_trylock_irqsave,
>>> which allows RT patches to properly manage the irq semantics.
>> Looks OK with me on first sight, I'll keep it on my stack and push it 
>> upstream after Jesse looks it over.
>>
>> Which -RT paches make this pop up btw? I'd like to repro it.
>>
> 
> Well, I'm not an expert on the realtime patches - but most any patch set 
> from Ingo seems to set this off - we've run through a bunch all the way 
> since 2.6.10.

that's bizarre, and would imply that Ingo himself never spotted this in ages, 
not to mention never tell us about it?

Ingo?
