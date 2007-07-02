From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 18:08:22 -0400
Message-ID: <46897756.1000005@garzik.org>
References: <4688F512.3030801@garzik.org> <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com> <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net> <20070702214238.GA7085@infradead.org> <46897611.9020207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54847 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757483AbXGBWIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 18:08:30 -0400
In-Reply-To: <46897611.9020207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> I suppose I can fix those, but I really don't understand what all the 
> fuzz is about here. We're only conserving memory and staying far away 
> from the real risks of bitmasks, so forgive me if I don't grasp the 
> problem.

Be it machine ints or bitfields, you're not conserving memory.  Think 
about struct padding.

As to the overall question, I already posted a long list of problems 
with bitfields.  Shall I repeat?

	Jeff


