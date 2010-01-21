From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Problems with tg3 driver after lowering the MTU
Date: Thu, 21 Jan 2010 15:27:23 +0000
Message-ID: <1264087643.2794.2.camel@achroite.uk.solarflarecom.com>
References: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Szilveszter Ordog <slipszi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30669 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0AUP10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 10:27:26 -0500
In-Reply-To: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-21 at 16:21 +0100, Szilveszter Ordog wrote:
> After the MTU is lowered (e.g. to 1420) on a tg3-driven interface,
> received packets larger than that (e.g. 1500 bytes) are silently
> discarded by the driver. Therefore the system doesn't send ICMP
> fragmentation-needed packets and the other side doesn't detect this
> condition.
> 
> Is this a known bug?

I don't believe this a bug.  Within a local network, MTU should be set
the same for all interfaces.  Routers that connect networks with
different MTUs will generate the fragmentation-needed message as
appropriate.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

