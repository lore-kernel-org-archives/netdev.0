From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 19:39:25 +0200
Message-ID: <20130704173925.GA4429@netboy>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
 <20130702142420.GC14630@netboy>
 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
 <20130703183035.GA4446@netboy>
 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
 <20130704053605.GC4457@netboy>
 <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
 <20130704155339.GA15214@netboy>
 <1372954878.1853.6.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:48100 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756657Ab3GDRji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 13:39:38 -0400
Received: by mail-ea0-f181.google.com with SMTP id a15so961409eae.12
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 10:39:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372954878.1853.6.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 04, 2013 at 05:21:18PM +0100, Ben Hutchings wrote:
> 
> But that is the opposite of what we're talking about.  Say the card has,
> 16 functions resulting in net devices eth0-eth15, each of which can
> access the same physical clock.  You said it's OK to have read-only
> aliases for a clock, so then there might be a writable /dev/ptp0 and
> read-only /dev/ptp1-ptp15.  What is the proper association between net
> devices and clock devices?

But the card doesn't have 16 plugs, or does it?

I understood you to have meant that the card has one physical plug,
shared between one host and fifteen guests. Or maybe I am total
confused. No, I am surely confused.

Anyhow, if a host is multihomed, then ideally all of the interfaces
share one and the same clock. But, if the only purpose of the multiple
interfaces in the VM host is to assign them to VM guests, then I guess
it doesn't matter very much how they appear in the VM host.

Richard
