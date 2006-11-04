From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 17:35:59 -0800
Message-ID: <454BEE7F.2020607@intel.com>
References: <20061103152025.5d27bd8d@freekitty>	<454BD44D.2060005@intel.com> <20061103154820.37f05a13@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54935 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1752549AbWKDBgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 20:36:04 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103154820.37f05a13@freekitty>
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
> It seems odd because that means you can never make a device fully deaf.

sure you can, just turn off WoL and e1000 will really shutdown (at least, I hope :))

Auke
