From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 17:53:08 -0800
Message-ID: <454BF284.8020009@intel.com>
References: <20061103152025.5d27bd8d@freekitty>	<454BD5FD.2030502@pobox.com>	<20061103.160230.71088561.davem@davemloft.net> <20061103161121.7533b32c@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36451 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1753569AbWKDBxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 20:53:09 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103161121.7533b32c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 03 Nov 2006 16:02:30 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Jeff Garzik <jgarzik@pobox.com>
>> Date: Fri, 03 Nov 2006 18:51:25 -0500
>>
>>> The purpose of WOL is being able to turn on a system remotely, if it is 
>>> in a power-off or sleep state.
>>>
>>> So, if the system is -on- and the interface is down and/or driver is 
>>> unloaded, are you saying WOL is a problem somehow?
>> Stephen is saying that if you down an interface, it should disable
>> that WoL functionality.
>>
>> I guess you can argue that, like IP addresses, this WoL thing is an
>> attribute of the "system".
> 
> Looking harder. The semantic needs to be WOL is okay if driver is loaded
> and device is up or down. But the default for WOL should be disabled until
> enabled by ethtool (or parameter).

Since this is enabled already in the BIOSes for most systems (or disabled, and 
switcheable by the user), I'd say we can let the driver handle the default (on for most 
cards) already. The BIOS can also handle a WoL call after a (long) powerfailure, before 
the OS boots, so disabling it in the OS would be quite useless in that case: the BIOS 
would override it anyway.

Doesn't sound like a problem you can solve in the driver layer...

Cheers,

Auke
