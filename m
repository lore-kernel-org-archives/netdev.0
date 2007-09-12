From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Wed, 12 Sep 2007 12:30:29 +0100
Message-ID: <46E7CDD5.3060306@katalix.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com> <46E1DDC5.8040202@pobox.com> <46E700A3.5010000@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:48299 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764742AbXILLau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 07:30:50 -0400
In-Reply-To: <46E700A3.5010000@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
> Jeff Garzik wrote:
>> David Acker wrote:
>>> Let me know if there is any other information I can provide you.  I 
>>> will look through the code to see what could be going on with your 
>>> machine.  I will also look into reproducing these results with a 
>>> newer kernel.  This may be tricky since compulab's patches are pretty 
>>> stale and don't always apply easily.
>>
>>
>> pktgen outputs for the various cases modified/unmodified[/others?] 
>> would be nice, if you have a spot of time.
>>
>>     Jeff
> 
> I am not familiar with pktgen but I seem to have it working for a simple 
> test.
> I edited the 1-1 example from 
> ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/ .  
> The results with and without the patch are below. 

It looks like you ran pktgen on the embedded system, which exercised 
only the transmit path. Auke indicated that the lockup was in the RU. 
Have you run pktgen on a test system to fire packets at the embedded 
system at max rate? Also test what happens when you fire packets in both 
directions simultaneously.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

