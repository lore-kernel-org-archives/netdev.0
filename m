From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 16:33:26 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801301629420.19938@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <47A0CD3B.3050502@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:54873 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbYA3Wdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 17:33:39 -0500
In-Reply-To: <47A0CD3B.3050502@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thank you for the suggestions and questions.

>> We've connected a pair of modern high-performance boxes with integrated 
>> copper Gb/s Intel NICS, with an ethernet crossover cable, and have run some 
>> netperf full duplex TCP tests.  The transfer rates are well below wire 
>> speed.  We're reporting this as a kernel bug, because we expect a vanilla 
>> kernel with default settings to give wire speed (or close to wire speed) 
>> performance in this case. We DO see wire speed in simplex transfers. The 
>> behavior has been verified on multiple machines with identical hardware.
>
> Try using NICs in the pci-e slots.  We have better luck there, as you 
> usually have more lanes and/or higher quality NIC chipsets available in 
> this case.

It's a good idea.  We can try this, though it will take a little time to 
organize.

> Try a UDP test to make sure the NIC can actually handle the throughput.

I should have mentioned this in my original post -- we already did this.

We can run UDP wire speed full duplex (over 900 Mb/s in each direction, at 
the same time). So the problem stems from TCP or is aggravated by TCP. 
It's not a hardware limitation.

> Look at the actual link usage as reported by the ethernet driver so that 
> you take all of the ACKS and other overhead into account.

OK.  We'll report on this as soon as possible.

> Try the same test using 10G hardware (CX4 NICs are quite affordable 
> these days, and we drove a 2-port 10G NIC based on the Intel ixgbe 
> chipset at around 4Gbps on two ports, full duplex, using pktgen). As in 
> around 16Gbps throughput across the busses.  That may also give you an 
> idea if the bottleneck is hardware or software related.

OK.  That will take more time to organize.

Cheers,
 	Bruce
>
