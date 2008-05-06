From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Tue, 6 May 2008 08:12:25 -0700
Message-ID: <20080506081225.637df034.akpm@linux-foundation.org>
References: <200804301925.m3UJPc72001651@hera.kernel.org>
	<20080501120858.207b6dd6.akpm@linux-foundation.org>
	<20080502160530.GN14219@solarflare.com>
	<20080502110908.93c79d81.akpm@linux-foundation.org>
	<20080506125008.GA2217@solarflare.com>
	<20080506072442.82a834c8.akpm@linux-foundation.org>
	<20080506150450.GB2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49168 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752799AbYEFPM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 11:12:28 -0400
In-Reply-To: <20080506150450.GB2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 16:04:53 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:

> > or
> > 
> >  	while (*dma_done != FALCON_STATS_DONE) {
> > 		udelay(1);
> > 		if (++timeout > TIMEOUT)
> > 			goto timeout;
> > 	}
>  
> On some architectures udelay() is defined using inline assembly that is not
> specified as clobbering memory.  So the compiler need not reload *dma_done
> after calling it, and this doesn't work.

So pop a cpu_relax() in there as the document describes?
