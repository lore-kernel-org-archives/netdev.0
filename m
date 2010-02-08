From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: MAX_SKB_FRAGS and GRO
Date: Mon, 08 Feb 2010 19:12:00 +0000
Message-ID: <1265656320.2092.51.camel@achroite.uk.solarflarecom.com>
References: <20100208100306.GQ32246@kryten>
	 <20100208124704.GA8538@gondor.apana.org.au>
	 <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
	 <4B704FAF.4010209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38785 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab0BHTMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 14:12:05 -0500
In-Reply-To: <4B704FAF.4010209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-08 at 09:53 -0800, Rick Jones wrote:
> >>First of all this isn't GRO, but RSC.  With GRO we impose extra
> >>restrictions on what packets can be merged while RSC is more
> >>permissive.
> > 
> > 
> > Herbert is right.  Just for clarity lets not call it "hardware GRO" but 
> > instead just call it RSC or hardware RSC (receive side coalescing)
> 
> I'll paint a stripe on the bikeshed and suggest something even more 
> explicit - if it is the hardware, how about HRC (Hardware Receive 
> Coalescing) or NRC (Nic Receive Coalescing).

The term 'Large Receive Offload' (LRO) has been around for a while;
what's wrong with that?  Qualify it with 'hardware' (HLRO) if necessary.

Any name involving 'coalescing' would easily be confused with interrupt
moderation, which ethtool calls coalescing.  Also, using anything close
to a proprietary name would only reward and encourage the marketing
geniuses who invent redundant and confusing terminology.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

