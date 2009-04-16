From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:02:36 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161500020.15835@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <1239905279.3203.30.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:46325 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550AbZDPTJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:09:52 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BFDF682C310
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:19:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tFglY0yBWVku for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 15:19:37 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5773182C30C
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:19:37 -0400 (EDT)
In-Reply-To: <1239905279.3203.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Ben Hutchings wrote:

> On Thu, 2009-04-16 at 12:10 -0400, Christoph Lameter wrote:
> > The following are results of lantency measurements using udpping
> > (available from http://gentwo.org/ll). It shows that significant latencies
> > were added since 2.6.27. I surely wish we could get back to times below 90
> > microseconds.
> [...]
>
> This "90 microseconds" figure is specific to a particular driver and
> hardware.  Have you verified that it applies to others?  The variation
> you've reported is tiny compared to the improvements that can be made or
> lost by hardware tuning.

The RX delay can influence this of course and so can the driver. But the
measurements are with the same RX delay and the same driver. Variations
are up to 20% which is not tiny and its only due to different kernel
versions.

