From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based =?iso-8859-1?q?PCI=09Express?= adapters...
Date: Tue, 3 Jul 2007 00:10:24 +0200
Message-ID: <200707030010.25431.mb@bu3sch.de>
References: <4688F512.3030801@garzik.org> <20070702214238.GA7085@infradead.org> <46897611.9020207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39785
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105AbXGBWLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 18:11:15 -0400
In-Reply-To: <46897611.9020207@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 July 2007 00:02:57 Kok, Auke wrote:
> well, FWIW when I started looking at adding these flags I looked in various 
> subsystems in the kernel and picked an implementation that suited. Guess what 
> pci.h has? ...:
> 
> 	unsigned int msi_enabled:1;
> 	unsigned int msix_enabled:1;
> 
> this is literally where I copied the example from
> 
> I suppose I can fix those, but I really don't understand what all the fuzz is 
> about here. We're only conserving memory and staying far away from the real 

I'm not sure if these bitfields actually _do_ conserve memory.
Generated code gets bigger (need bitwise masks and stuff).
Code also needs memory. It probably only conserves memory, if the
structure is instanciated a lot.

-- 
Greetings Michael.
