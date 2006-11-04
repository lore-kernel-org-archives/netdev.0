From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 17:36:45 -0800
Message-ID: <454BEEAD.70108@intel.com>
References: <20061103152025.5d27bd8d@freekitty>	<454BD44D.2060005@intel.com> <20061103155006.68099f6e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40880 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1753557AbWKDBgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 20:36:47 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103155006.68099f6e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 03 Nov 2006 15:44:13 -0800
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> It doesn't seem like a good idea for a network device to wake the system
>>> if it is down.
>> before suspend existed this was the only useful case for WoL. Why does it not seem a 
>> good idea to wake up a machine that was shutdown (and thus the interface `downed`) ?
>>
>> Auke
> 
> Interestingly it looks like e100 is one of the ones that only wakes from suspend (not when down).

that would be a bug, I'll have to get that checked especially after the latest changes 
to it.

Auke
