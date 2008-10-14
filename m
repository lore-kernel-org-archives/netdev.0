From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS
 dependency
Date: Tue, 14 Oct 2008 19:43:05 -0400
Message-ID: <48F52E89.9050104@redhat.com>
References: <1224023293-8592-1-git-send-email-afleming@freescale.com>	<20081014.154422.192817982.davem@davemloft.net>	<2acbd3e40810141621p31ba3ccdic909fc4634b5ef26@mail.gmail.com> <20081014.163359.110730186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50086 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbYJNXnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 19:43:20 -0400
In-Reply-To: <20081014.163359.110730186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Andy Fleming" <afleming@gmail.com>
> Date: Tue, 14 Oct 2008 18:21:44 -0500
> 
>> Argh.  From what I could see, we have request_irq, free_irq,
>> disable_irq, enable_irq, and disable_irq_nosync.  For the PHYLIB, it
>> shouldn't be difficult to modify things so that it doesn't compile in
>> interrupt support if the system doesn't support them.  Shouldn't, that
>> is, if there's some config option that tells me whether those
>> functions exist.
> 
> I think this whole situation with s390 is rediculious.
> 
> If s390 is weird and lacks these fundamental things, that's fine.
> What isn't fine is how we're handling this.
> 
> No code should care or even be aware of this.
> 
> S390 should simply provide a set of dummy DMA and interrupt interface
> stubs that always fail and return an error value.
> 
> Then we can get rid of this S390 Kconfig stuff which has been spewed
> all over the place.

"depends on PCI" has always worked for me.  Any reason we can't use that 
here?

-- Chris
