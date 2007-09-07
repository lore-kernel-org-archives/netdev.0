From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Fri, 07 Sep 2007 14:18:47 -0700
Message-ID: <46E1C037.1090507@intel.com>
References: <20070831205430.7209E46C20E@localhost> <46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com> <46E1BCA3.5030201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Acker <dacker@roinet.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Milton Miller <miltonm@bga.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Scott Feldman <sfeldma@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbXIGVSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 17:18:54 -0400
In-Reply-To: <46E1BCA3.5030201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> David Acker wrote:
>> Kok, Auke wrote:
>>> first impressions are not good: pings are erratic and shoot up to 3 
>>> seconds. In an overnight stress test, the receive unit went offline and 
>>> never came back up (TX still working).
>>>
>>> it sounds like something in the logic is suspending the ru too much, but 
>>> I haven't had time to look deeply into the code yet.
>> I don't have an e100 enabled x86 box handy but I will look into getting one setup.
>>
>> I just applied this patch to my PXA255 based system http://www.compulab.co.il/x255/html/x255-cm-datasheet.htm .
>> It is running 2.6.18.4 plus compulab patches plus some hostap patches plus the e100 patch.  I get:
>>
>> pings going from the embedded system to a desktop machine.
>> 100 packets transmitted, 100 received, 0% packet loss, time 98996ms
>> rtt min/avg/max/mdev = 0.239/0.728/1.512/0.571 ms
>>
>> Pings going the from the desktop machine to the embedded system
>> 100 packets transmitted, 100 received, 0% packet loss, time 99217ms
>> rtt min/avg/max/mdev = 0.206/0.876/1.473/0.575 ms
> 
> ok, I just got a note from our lab saying that that particular system has the 
> freak ping times even without your patch applied 8)
> 
> ignoring the ping issue, we still have the ru offline, but that could have 
> possibly been caused by whatever is causing this ping issue... More testing is 
> needed, and I'll try to find a system without the ping issue here first.

update: Emil reports that the unit with the RU hang did not have bad ping times 
to begin with, pointing to a problem with the patch for sure now...

Auke
