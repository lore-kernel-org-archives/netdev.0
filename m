From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Mon, 02 Jul 2007 18:16:20 -0400
Message-ID: <46897934.5040101@garzik.org>
References: <4688F512.3030801@garzik.org> <20070702214238.GA7085@infradead.org> <46897611.9020207@intel.com> <200707030010.25431.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54939 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756323AbXGBWQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 18:16:26 -0400
In-Reply-To: <200707030010.25431.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 03 July 2007 00:02:57 Kok, Auke wrote:
>> well, FWIW when I started looking at adding these flags I looked in various 
>> subsystems in the kernel and picked an implementation that suited. Guess what 
>> pci.h has? ...:
>>
>> 	unsigned int msi_enabled:1;
>> 	unsigned int msix_enabled:1;
>>
>> this is literally where I copied the example from
>>
>> I suppose I can fix those, but I really don't understand what all the fuzz is 
>> about here. We're only conserving memory and staying far away from the real 
> 
> I'm not sure if these bitfields actually _do_ conserve memory.
> Generated code gets bigger (need bitwise masks and stuff).
> Code also needs memory. It probably only conserves memory, if the
> structure is instanciated a lot.

Actually, that's a good point.  On several RISC architectures it 
certainly generates bigger code.

	Jeff



