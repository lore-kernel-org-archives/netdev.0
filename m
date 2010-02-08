From: Rick Jones <rick.jones2@hp.com>
Subject: Re: MAX_SKB_FRAGS and GRO
Date: Mon, 08 Feb 2010 09:53:51 -0800
Message-ID: <4B704FAF.4010209@hp.com>
References: <20100208100306.GQ32246@kryten>	<20100208124704.GA8538@gondor.apana.org.au> <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:18348 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab0BHRxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 12:53:50 -0500
In-Reply-To: <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>First of all this isn't GRO, but RSC.  With GRO we impose extra
>>restrictions on what packets can be merged while RSC is more
>>permissive.
> 
> 
> Herbert is right.  Just for clarity lets not call it "hardware GRO" but 
> instead just call it RSC or hardware RSC (receive side coalescing)

I'll paint a stripe on the bikeshed and suggest something even more 
explicit - if it is the hardware, how about HRC (Hardware Receive 
Coalescing) or NRC (Nic Receive Coalescing).

rick jones
