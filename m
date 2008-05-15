From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 17:39:39 +0100
Message-ID: <20080515173939.1ec968be@core>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	<20080515142154.0595e475@core>
	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Chris Peterson" <cpeterso@cpeterso.com>, <jeff@garzik.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:59638 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754007AbYEOQuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 12:50:46 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
> customers who also want the same.

They should be made to read the Debian ssh security report - three times
and understand the same would apply to them if something did cause their
network packet arrivals to be observed or non-random

Far better would be to get your CPU guys to put an RNG back into the
systems or on the CPU die ala VIA. Given I've even seen people using VIA
boxes as a random number feeder (streaming random numbers over SSL) there
is clearly a demand 8)

Alan
