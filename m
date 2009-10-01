From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: irqname based on pci address
Date: Thu, 01 Oct 2009 15:17:32 -0700 (PDT)
Message-ID: <20091001.151732.61755550.davem@davemloft.net>
References: <20091001122720.3822bdd3@leela>
	<20091001101146.3368b4a4@s6510>
	<20091001200355.7635a8a9@leela>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752927AbZJAWRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:17:12 -0400
In-Reply-To: <20091001200355.7635a8a9@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu, 1 Oct 2009 20:03:55 +0200

> Dne Thu, 1 Oct 2009 10:11:46 -0700 Stephen Hemminger napsal(a):
>> This is based on Michal Schmidt fix for skge.
>> 
>> Most network drivers request their IRQ when the interface is
>> activated. sky2 does it in ->probe() instead, because it can work
>> with two-port cards where the two net_devices use the same IRQ. This
>> works fine most of the time, except in some situations when the
>> interface gets renamed. Consider this example:
 ...
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Reviewed-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
