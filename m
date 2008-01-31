From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 13:48:37 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801311340270.14403@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu> <47A20E9E.7070503@intel.com>
 <Pine.LNX.4.63.0801311251040.14403@trinity.phys.uwm.edu> <47A22241.70600@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:45344 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbYAaTsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:48:51 -0500
In-Reply-To: <47A22241.70600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Auke,

>> Based on the discussion in this thread, I am inclined to believe that
>> lack of PCI-e bus bandwidth is NOT the issue.  The theory is that the
>> extra packet handling associated with TCP acknowledgements are pushing
>> the PCI-e x1 bus past its limits.  However the evidence seems to show
>> otherwise:
>>
>> (1) Bill Fink has reported the same problem on a NIC with a 133 MHz
>> 64-bit PCI connection.  That connection can transfer data at 8Gb/s.
>
> That was even a PCI-X connection, which is known to have extremely good latency
> numbers, IIRC better than PCI-e? (?) which could account for a lot of the
> latency-induced lower performance...
>
> also, 82573's are _not_ a serverpart and were not designed for this 
> usage. 82546's are and that really does make a difference.

I'm confused.  It DOESN'T make a difference! Using 'server grade' 82546's 
on a PCI-X bus, Bill Fink reports the SAME loss of throughput with TCP 
full duplex that we see on a 'consumer grade' 82573 attached to a PCI-e x1 
bus.

Just like us, when Bill goes from TCP to UDP, he gets wire speed back.

Cheers,
 	Bruce
