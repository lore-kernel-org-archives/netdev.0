From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 15 May 2007 23:20:54 +0200
Message-ID: <20070515212054.GH13958@xi.wantstofly.org>
References: <464034CF.20700@wpkg.org> <f1s2eu$26p$1@sea.gmane.org> <20070509092132.GB6976@xi.wantstofly.org> <200705091135.06405.marcus@better.se> <20070509110415.GA7513@xi.wantstofly.org> <4641D920.2020508@roinet.com> <47B3C8DF-D72E-45D4-8381-D77FDCD89DB8@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Acker <dacker@roinet.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Marcus Better <marcus@better.se>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:60876 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbXEOVU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:20:58 -0400
Content-Disposition: inline
In-Reply-To: <47B3C8DF-D72E-45D4-8381-D77FDCD89DB8@cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 03:45:53PM +0100, Michael-Luke Jones wrote:

> No-one is saying that this driver should not be mainlined before it  
> has LE support. All that I said was:
> 
> > Personally I'd like LE ethernet tested and working before we push.
> 
> The alternative would be to explicitly state in Kconfig that LE arm  
> is broken with this driver, so that this could be fixed later.

The driver does bomb out during compile if __ARMEB__ isn't defined,
but that apparently wasn't good enough.


> Please can we not blow this out of proportion, it really isn't that  
> big a deal. The irony is that fixing Krzysztof's driver to work on LE  
> will probably be quite easy, given that we already have a working LE  
> driver from Christian.

I'm looking forward to your patch.
