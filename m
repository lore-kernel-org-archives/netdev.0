From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 08:01:46 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:57135 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbYA3OCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 09:02:04 -0500
In-Reply-To: <20080130.055333.192844925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for your note.

>> (The performance of a full duplex stream should be close to 1Gb/s in
>> both directions.)
>
> This is not a reasonable expectation.
>
> ACKs take up space on the link in the opposite direction of the
> transfer.
>
> So the link usage in the opposite direction of the transfer is
> very far from zero.

Indeed, we are not asking to see 1000 Mb/s.  We'd be happy to see 900 
Mb/s.

Netperf is trasmitting a large buffer in MTU-sized packets (min 1500 
bytes).  Since the acks are only about 60 bytes in size, they should be 
around 4% of the total traffic.  Hence we would not expect to see more 
than 960 Mb/s.

We have run these same tests on older kernels (with Broadcomm NICS) and 
gotten above 900 Mb/s full duplex.

Cheers,
     Bruce
