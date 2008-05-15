From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 14:14:59 -0400
Message-ID: <482C7DA3.1090809@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45614 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198AbYEOSPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 14:15:03 -0400
In-Reply-To: <20080515173939.1ec968be@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>> In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
>> customers who also want the same.
> 
> They should be made to read the Debian ssh security report - three times
> and understand the same would apply to them if something did cause their
> network packet arrivals to be observed or non-random
> 
> Far better would be to get your CPU guys to put an RNG back into the
> systems or on the CPU die ala VIA. Given I've even seen people using VIA
> boxes as a random number feeder (streaming random numbers over SSL) there
> is clearly a demand 8)

The Treacherous Platform Module includes an RNG.

Someone (hi Jesse?) should implement support for TPM_GetRandom.

All the specs are public, and the hardware is already in users' hands.

	Jeff




