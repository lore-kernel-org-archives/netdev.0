From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 15:11:12 -0700
Message-ID: <465F4800.8080103@intel.com>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <465E0149.6030307@intel.com> <20070531005147.GA30628@gondor.apana.org.au> <465E5442.7010503@intel.com> <20070531050616.GA32391@gondor.apana.org.au> <465EE1A7.6050901@intel.com> <20070531214947.GA9428@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Doug Chapman <doug.chapman@hp.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27953 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218AbXEaWLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 18:11:14 -0400
In-Reply-To: <20070531214947.GA9428@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, May 31, 2007 at 07:54:31AM -0700, Kok, Auke wrote:
>> so how about calling netif_poll_disable() before we register the net_device?
> 
> Yes that should work.  Let's move the other two netif_ calls while we're
> at it.
>  
>> well no, if we make the watchdog (this is something I've already 
>> implemented locally and -mm has it for instance) run as delayed work we can 
>> just schedule a watchdog run instead of firing an interrupt.
> 
> OK.  The only thing I'm worried about is if we're uncovering some
> underlying problem with the platform with respect to memory barriers
> then we should get to the bottom of it first before making this problem
> disappear.

agreed. I will try to send a patch to do this later today.

Auke
