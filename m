From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 14 Feb 2012 21:51:29 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F8C83B@ORSMSX106.amr.corp.intel.com>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F8C728@ORSMSX106.amr.corp.intel.com>
	<20120214.163138.447136245539138324.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F8C7D6@ORSMSX106.amr.corp.intel.com>
 <20120214.164807.1861862972661744092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21280 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757319Ab2BNVvC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:51:02 -0500
In-Reply-To: <20120214.164807.1861862972661744092.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 14, 2012 1:48 PM
> To: Rose, Gregory V
> Cc: bhutchings@solarflare.com; netdev@vger.kernel.org
> Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Tue, 14 Feb 2012 21:41:57 +0000
> 
> > The second item sort of matches what I said in the last reply.  Base
> > the buffer allocation size on the maximum possible for the given
> > extension which as I said, is up to 255 VFs for the case under
> > immediate consideration.
> 
> That's what we're trying to avoid, because that will result in multi-order
> allocations (which are failure prone) when most of the time such a large
> buffer is entirely unnecessary.
> 
> > The first one seems like a good idea but I wonder what the effect
> > would be on a system with a large number of interfaces.
> 
> It's already expensive to dump a large number of devices, and in
> effect you'll be optimizing the buffer allocation which could in fact
> end up helping performance.

OK, I'll see what I can do.

- Greg
