From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Minimizing TCP latency
Date: Tue, 30 Mar 2010 04:20:03 +0100
Message-ID: <1269919203.8653.435.camel@localhost>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
	 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
	 <1269876229.2092.3.camel@achroite.uk.solarflarecom.com>
	 <7c93bf1e1003291936v4b0f610eiae07c236dfc72047@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hoyt <benhoyt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33647 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179Ab0C3DUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 23:20:08 -0400
In-Reply-To: <7c93bf1e1003291936v4b0f610eiae07c236dfc72047@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-30 at 15:36 +1300, Ben Hoyt wrote:
> > Choose low-latency NICs.  Read the tuning guide, but run your own
> > benchmarks.
> 
> Is this the tuning guide you're referring to?
> http://fasterdata.es.net/TCP-tuning/linux.html

No, and that doesn't say anything about latency.

There are quite a few generic tuning knobs (buffer and ring sizes,
interrupt moderation and affinity).  However, many vendors of
high-performance NICs, including Solarflare, provide a performance
tuning guide as part of their documentation, which can include
hardware-specific advice.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

