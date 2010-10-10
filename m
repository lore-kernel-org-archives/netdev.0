From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add IRQF_SAMPLE_RANDOM Flag to forcedeth
Date: Sun, 10 Oct 2010 02:09:24 +0100
Message-ID: <20101010010924.GB15074@solarflare.com>
References: <4CB0FEA6.3030206@netscape.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick Simmons <linuxrocks123@netscape.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58167 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806Ab0JJBJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 21:09:27 -0400
Content-Disposition: inline
In-Reply-To: <4CB0FEA6.3030206@netscape.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Simmons wrote:
> This patch adds the IRQF_SAMPLE_RANDOM flag to the forcedeth driver, 
> allowing the interrupt timing for forcedeth to be used for entropy 
> generation.  This should help /dev/random generate more secure random 
> numbers on machines using this driver.
[...]

We don't enable this for network drivers any more because:

1. At high packet rates, interrupt moderation makes interrupts very
regular.
2. At low packet rates, a malicious sender can control the interrupt
timing.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
