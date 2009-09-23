From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 12:03:01 -0700
Message-ID: <4ABA70E5.9070404@hp.com>
References: <4ABA4F8B.6040504@candelatech.com>	<1253730766.2538.28.camel@localhost.localdomain>	<4ABA6D0D.8010200@candelatech.com> <1253731834.2538.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:32257 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbZIWTC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 15:02:59 -0400
In-Reply-To: <1253731834.2538.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Next time you guys re-compile your hardware, please consider adding byte counters :)
> 
> 
> On 10G adapters, byte counters can skyrocket quickly, so we'd need to
> read them often to avoid them wrapping. 

10G Ethernet is ~1.16 GB/s (GiB/s for purists I guess) for simplicity, call that 
2GB/s or 2^31 bytes per second.  If the counter is 64 bits, that would suggest 
wrap in 2^64/2^31 or 2^33 seconds right?  Or have I made some nasty math error? 
  I'm having quit a difficult time imagining that someone would have 32 bit 
counters in a 10G NIC.

rick jones
