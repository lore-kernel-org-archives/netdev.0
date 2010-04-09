From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Fri, 09 Apr 2010 17:55:41 +0100
Message-ID: <1270832141.2108.6.camel@achroite.uk.solarflarecom.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>
	 <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	 <w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
	 <1270755356.5055.23.camel@achroite.uk.solarflarecom.com>
	 <j2r97949e3e1004081543h6258125dm60083556ff28fa88@mail.gmail.com>
	 <4BBE78E2.2000709@garzik.org>
	 <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55419 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab0DIQzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 12:55:45 -0400
In-Reply-To: <x2o97949e3e1004090943o4b6b29e5pd261e2cb4c7f421d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't top-post.

On Fri, 2010-04-09 at 09:43 -0700, Laurent Chavey wrote:
> isn't the existing ETHTOOL_TEST ioctl use for something like self test ?
> 
> the intent of this patch is to enable a mode whereby one could run
> netperf / iperf and other application  and have the packets sent and
> received by the driver.
[...]

If you send to a local address, the traffic will be routed over the
internal loopback interface.  Applications will not use a network
interface in loopback unless they override routing or send raw packets.
netperf and iperf don't allow you todo that, so far as I'm ware.

Also those applications are *performance* tests; they are not very
useful for fault-finding.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

