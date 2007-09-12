From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Wed, 12 Sep 2007 16:11:21 -0400
Message-ID: <46E847E9.4010601@roinet.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com> <46E1DDC5.8040202@pobox.com> <46E700A3.5010000@roinet.com> <46E7CDD5.3060306@katalix.com>
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
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:56275
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbXILULV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 16:11:21 -0400
In-Reply-To: <46E7CDD5.3060306@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> David Acker wrote:
>> Jeff Garzik wrote:
>>> pktgen outputs for the various cases modified/unmodified[/others?] 
>>> would be nice, if you have a spot of time.
>>>
>>>     Jeff
>>
>> I am not familiar with pktgen but I seem to have it working for a 
>> simple test.
>> I edited the 1-1 example from 
>> ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/examples/ 
>> .  The results with and without the patch are below. 
> 
> It looks like you ran pktgen on the embedded system, which exercised 
> only the transmit path. Auke indicated that the lockup was in the RU. 
> Have you run pktgen on a test system to fire packets at the embedded 
> system at max rate? Also test what happens when you fire packets in both 
> directions simultaneously.
> 
It appears that running pktgen between my pc and the embedded device at the same time eventually hangs the RU.  I will 
be looking into this failure in detail and report back when I know more.  Thanks for bearing with me on this!
-Ack
