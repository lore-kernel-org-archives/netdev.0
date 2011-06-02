From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TX watchdog vs link-layer flow control
Date: Thu, 02 Jun 2011 22:01:42 +0100
Message-ID: <1307048502.2812.67.camel@bwh-desktop>
References: <1307047720.2812.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36810 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615Ab1FBVBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 17:01:45 -0400
In-Reply-To: <1307047720.2812.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also: given that the watchdog fires if *any* TX queue is stopped, that
seems to mean that on a device with hardware TX priority it could be
triggered for a TX queue with low priority if the link is filled with
higher-priority TX packets for long enough.  (This depends on how 'hard'
the priorities are, of course.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

