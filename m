From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 17:44:30 -0800
Message-ID: <454BF07E.2070207@intel.com>
References: <20061103152025.5d27bd8d@freekitty>	<454BD44D.2060005@intel.com>	<20061103155006.68099f6e@freekitty>	<454BEEAD.70108@intel.com> <20061103173751.581ca5ab@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36170 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1753169AbWKDBom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 20:44:42 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103173751.581ca5ab@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 03 Nov 2006 17:36:45 -0800
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Fri, 03 Nov 2006 15:44:13 -0800
>>> Auke Kok <auke-jan.h.kok@intel.com> wrote:
>>>
>>>> Stephen Hemminger wrote:
>>>>> It doesn't seem like a good idea for a network device to wake the system
>>>>> if it is down.
>>>> before suspend existed this was the only useful case for WoL. Why does it not seem a 
>>>> good idea to wake up a machine that was shutdown (and thus the interface `downed`) ?
>>>>
>>>> Auke
>>> Interestingly it looks like e100 is one of the ones that only wakes from suspend (not when down).
>> that would be a bug, I'll have to get that checked especially after the latest changes 
>> to it.
>>
> 
> Sorry, my bad my test machine was not setup properly.

I don't blame you, WoL is one of the hardest features to get right, especially with all 
the various e100{,0} hardware and options that influence it (manageability, eeproms, etc).

On top of that there's this blob called BIOS messing it all up after a powercycle :)

Cheers,

Auke
