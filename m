From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 19:07:59 +0100
Message-ID: <1239905279.3203.30.camel@achroite>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:57170 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753132AbZDPSIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 14:08:05 -0400
In-Reply-To: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-16 at 12:10 -0400, Christoph Lameter wrote:
> The following are results of lantency measurements using udpping
> (available from http://gentwo.org/ll). It shows that significant latencies
> were added since 2.6.27. I surely wish we could get back to times below 90
> microseconds.
[...]

This "90 microseconds" figure is specific to a particular driver and
hardware.  Have you verified that it applies to others?  The variation
you've reported is tiny compared to the improvements that can be made or
lost by hardware tuning.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

