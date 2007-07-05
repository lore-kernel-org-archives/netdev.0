From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Thu, 05 Jul 2007 19:29:01 -0400
Message-ID: <468D7EBD.7020103@garzik.org>
References: <4688F512.3030801@garzik.org> <200707021716.49637.inaky@linux.intel.com> <468A4CDE.5010808@garzik.org> <200707031124.24529.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51854 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbXGEX3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 19:29:35 -0400
In-Reply-To: <200707031124.24529.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inaky Perez-Gonzalez wrote:
> On Tuesday 03 July 2007, Jeff Garzik wrote:
>> Inaky Perez-Gonzalez wrote:
>> Access to bitfields are not atomic within the machine int in which they 
>> are stored... you need to "unpack" the values stored in bitfields, even 
>> if they are single-bit bitfields.
> 
> Which we do manually when we don't use bitfields. Again, conceptually,
> there is no difference.

Practically speaking -- there are differences.

The "manual" method hides nothing from the programmer, while use of 
bitfields hides the lack of atomicity.

When you have programmers who make mistakes -- i.e. real humans -- these 
things matter.

But overall, it is not any one detail that discourages use of bitfields; 
it is the sum of all the reasons.  Practical experience, compiler 
technology, mistakes made (and not made), all point to avoiding bitfields.

	Jeff


