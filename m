From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 17:09:57 +0100
Message-ID: <47A1F2D5.5070709@aei.mpg.de>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <p738x265p7p.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:46673 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764781AbYAaQKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 11:10:25 -0500
In-Reply-To: <p738x265p7p.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi,

Andi Kleen wrote:
> Another issue with full duplex TCP not mentioned yet is that if TSO is used 
> the output  will be somewhat bursty and might cause problems with the 
> TCP ACK clock of the other direction because the ACKs would need 
> to squeeze in between full TSO bursts.
> 
> You could try disabling TSO with ethtool.

I just tried that:

https://n0.aei.uni-hannover.de/wiki/index.php/NetworkTestNetperf3

It seems that the numbers do get better (sweet-spot seems to be MTU6000 
with 914 MBit/s and 927 MBit/s), however for other settings the results 
vary a lot so I'm not sure how large the statistical fluctuations are.

Next test I'll try if it makes sense to enlarge the ring buffers.

Thanks

Carsten
