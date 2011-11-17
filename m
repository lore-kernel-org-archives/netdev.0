From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Thu, 17 Nov 2011 02:29:27 +0000
Message-ID: <1321496967.2885.65.camel@deadeye>
References: <1321490078.2709.86.camel@bwh-desktop>
	 <20111117011604.GA8683@mcarlson.broadcom.com>
	 <1321492892.9114.22.camel@nseg_linux_HP1.broadcom.com>
	 <20111116.203850.1548671990526136907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <mchan@broadcom.com>, <mcarlson@broadcom.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51836 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab1KQC3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 21:29:39 -0500
In-Reply-To: <20111116.203850.1548671990526136907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 20:38 -0500, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 16 Nov 2011 17:21:32 -0800
> 
> > 
> > On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
> >> > Finally, do these need to be inline?
> >> 
> >> I don't have a strong preference here either.  Phy code tends to be
> >> slower, so there isn't really a strong performance argument.  The
> >> implementations don't seem to be so large to argue against it though.
> >> Would you prefer they not be inlined?
> >> 
> > 
> > Since we are defining these in .h file, they need to be inline, right?
> > Otherwise multiple source files including the same .h file will have
> > conflict.
> 
> Yes, if you keep them in the header you have to keep them inline.
> 
> Ben, by suggesting to not inline them, is implicitly saying to put
> them out in a seperate *.c file somewhere, perhaps net/core/ethtool.c
> or similar.  With appropriate EXPORT_SYMBOL() added.

I was thinking of putting them in drivers/net/mii.c, like the other
functions declared extern in include/linux/mii.h.  That would require
'select MII' in Kconfig for the drivers using them.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
